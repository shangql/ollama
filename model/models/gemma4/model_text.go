package gemma4

import (
	"cmp"
	"math"

	"github.com/ollama/ollama/fs"
	"github.com/ollama/ollama/kvcache"
	"github.com/ollama/ollama/ml"
	"github.com/ollama/ollama/ml/nn"
	"github.com/ollama/ollama/ml/nn/rope"
	"github.com/ollama/ollama/model/input"
)

type TextModel struct {
	TokenEmbedding *nn.Embedding `gguf:"token_embd"`

	PerLayerTokenEmbedding *nn.Embedding `gguf:"per_layer_tok_embd"`
	PerLayerProjector      *nn.Linear    `gguf:"per_layer_model_proj"`
	PerLayerProjNorm       *nn.RMSNorm   `gguf:"per_layer_proj_norm"`

	TextLayers []TextLayer `gguf:"blk"`
	OutputNorm *nn.RMSNorm `gguf:"output_norm"`
	Output     *nn.Linear  `gguf:"output,alt:token_embd"`

	TextOptions
}

func (m *TextModel) Forward(ctx ml.Context, batch input.Batch, cache kvcache.Cache) (ml.Tensor, error) {
	positions := ctx.Input().FromInts(batch.Positions, len(batch.Positions))

	hiddenState := m.TokenEmbedding.Forward(ctx, batch.Inputs)
	hiddenState = hiddenState.Scale(ctx, math.Sqrt(float64(m.hiddenSize)))

	perLayerInputs := m.computePerLayerInputs(ctx, batch)

	firstSharedKeyValue := m.hiddenLayers - m.sharedKeyValueLayers
	for i, layer := range m.TextLayers {
		if i < firstSharedKeyValue {
			cache.SetLayer(i)
		} else if m.isLocal(i) {
			cache.SetLayer(firstSharedKeyValue - 2)
		} else {
			cache.SetLayer(firstSharedKeyValue - 1)
		}

		var layerType int
		ropeBase := m.ropeBase
		if m.isLocal(i) {
			layerType = 1
			ropeBase = m.ropeBaseLocal
		}

		cache.(*kvcache.WrapperCache).SetLayerType(layerType)

		perLayerInput := perLayerInputs.View(ctx, i*perLayerInputs.Stride(1), perLayerInputs.Dim(0), perLayerInputs.Stride(2), perLayerInputs.Dim(2))
		hiddenState = layer.Forward(ctx, hiddenState, perLayerInput, positions, cache, i >= firstSharedKeyValue, ropeBase, float64(m.activationSparsityScale[i]), &m.TextOptions)
	}

	hiddenState = m.OutputNorm.Forward(ctx, hiddenState, m.eps)
	logits := m.Output.Forward(ctx, hiddenState)

	if m.finalLogitSoftcap > 0 {
		logits = logits.Scale(ctx, 1.0/float64(m.finalLogitSoftcap))
		logits = logits.Tanh(ctx)
		logits = logits.Scale(ctx, float64(m.finalLogitSoftcap))
	}

	return logits, nil
}

func (m *TextModel) computePerLayerInputs(ctx ml.Context, batch input.Batch) ml.Tensor {
	if m.PerLayerTokenEmbedding == nil {
		return nil
	}

	perLayerEmb := m.PerLayerTokenEmbedding.Forward(ctx, batch.Inputs)
	perLayerEmb = perLayerEmb.Scale(ctx, math.Sqrt(float64(m.hiddenSizePerLayerInput)))
	perLayerEmb = perLayerEmb.Reshape(ctx, m.hiddenSizePerLayerInput, m.hiddenLayers, batch.Inputs.Dim(0), batch.Inputs.Dim(1))

	perLayerProj := m.PerLayerProjector.Forward(ctx, m.TokenEmbedding.Forward(ctx, batch.Inputs))
	perLayerProj = perLayerProj.Scale(ctx, math.Sqrt(float64(m.hiddenSize)))
	perLayerProj = perLayerProj.Reshape(ctx, m.hiddenSizePerLayerInput, m.hiddenLayers, batch.Inputs.Dim(1))
	perLayerProj = m.PerLayerProjNorm.Forward(ctx, perLayerProj, m.eps)

	perLayerProj = perLayerProj.Add(ctx, perLayerEmb)
	perLayerProj = perLayerProj.Scale(ctx, 1/math.Sqrt(2))

	return perLayerProj
}

func (m *TextModel) Shift(ctx ml.Context, layer int, key, shift ml.Tensor) (ml.Tensor, error) {
	ropeBase := m.ropeBase
	if m.isLocal(layer) {
		ropeBase = m.ropeBaseLocal
	}

	return m.applyRotaryPositionEmbeddings(ctx, key, shift, ropeBase), nil
}

type TextLayer struct {
	AttentionNorm     *nn.RMSNorm `gguf:"attn_norm"`
	Attention         *TextAttention
	PostAttentionNorm *nn.RMSNorm `gguf:"post_attention_norm"`

	MLPNorm     *nn.RMSNorm `gguf:"ffn_norm"`
	MLP         *TextMLP
	PostMLPNorm *nn.RMSNorm `gguf:"post_ffw_norm"`

	FFNPreNorm2  *nn.RMSNorm `gguf:"ffn_pre_norm_2"`
	FFNPostNorm1 *nn.RMSNorm `gguf:"ffn_post_norm_1"`
	FFNPostNorm2 *nn.RMSNorm `gguf:"ffn_post_norm_2"`

	FFNGateInp  *nn.Linear `gguf:"ffn_gate_inp"`
	FFNGateInpS *nn.Linear `gguf:"ffn_gate_inp_scale"`

	FFNGateExps   *nn.Linear `gguf:"ffn_gate_exps"`
	FFNUpExps     *nn.Linear `gguf:"ffn_up_exps"`
	FFNGateUpExps *nn.Linear `gguf:"ffn_gate_up_exps"`
	FFNDownExps   *nn.Linear `gguf:"ffn_down_exps"`

	PerLayerInputGate  *nn.Linear  `gguf:"per_layer_inp_gate"`
	PerLayerProjection *nn.Linear  `gguf:"per_layer_proj"`
	PostPerLayerNorm   *nn.RMSNorm `gguf:"per_layer_post_norm"`

	OutScale *nn.Linear `gguf:"layer_out_scale"`
}

func (l *TextLayer) Forward(ctx ml.Context, hiddenStates, perLayerInput, positions ml.Tensor, cache kvcache.Cache, sharedKV bool, ropeBase float32, activationSparsityScale float64, opts *TextOptions) ml.Tensor {
	residual := hiddenStates

	hiddenStates = l.AttentionNorm.Forward(ctx, hiddenStates, opts.eps)
	hiddenStates = l.Attention.Forward(ctx, hiddenStates, positions, cache, sharedKV, ropeBase, opts)
	hiddenStates = l.PostAttentionNorm.Forward(ctx, hiddenStates, opts.eps)
	hiddenStates = residual.Add(ctx, hiddenStates)

	residual = hiddenStates

	mlpOut := l.MLPNorm.Forward(ctx, hiddenStates, opts.eps)
	mlpOut = l.MLP.Forward(ctx, mlpOut)
	mlpOut = l.PostMLPNorm.Forward(ctx, mlpOut, opts.eps)
	mlpOut = residual.Add(ctx, mlpOut)

	moeOut := mlpOut
	isMoE := l.FFNGateInp != nil
	if isMoE {
		residual = moeOut

		moeOut = l.FFNPreNorm2.Forward(ctx, moeOut, opts.eps)

		tmp := moeOut.RMSNorm(ctx, nil, opts.eps)
		tmp = tmp.Scale(ctx, 1.0/float64(opts.hiddenSize))
		if l.FFNGateInpS != nil {
			tmp = tmp.Mul(ctx, l.FFNGateInpS.Forward(ctx, nil))
		}
		logits := l.FFNGateInp.Forward(ctx, tmp)

		moeOut = l.computeMoE(ctx, moeOut, logits, opts)

		moeOut = l.FFNPostNorm2.Forward(ctx, moeOut, opts.eps)
		moeOut = residual.Add(ctx, moeOut)
	}

	moeOut = l.PostMLPNorm.Forward(ctx, moeOut, opts.eps)

	if l.PerLayerInputGate != nil && perLayerInput != nil {
		gated := l.PerLayerInputGate.Forward(ctx, moeOut)
		gated = gated.GELU(ctx, perLayerInput)
		gated = l.PerLayerProjection.Forward(ctx, gated)
		gated = l.PostPerLayerNorm.Forward(ctx, gated, opts.eps)
		moeOut = moeOut.Add(ctx, gated)
	}

	if l.OutScale != nil {
		moeOut = moeOut.Mul(ctx, l.OutScale.Forward(ctx, nil))
	}

	return moeOut
}

func (l *TextLayer) computeMoE(ctx ml.Context, hiddenStates, logits ml.Tensor, opts *TextOptions) ml.Tensor {
	numExperts := l.FFNGateExps != nil && l.FFNUpExps != nil && l.FFNDownExps != nil

	if numExperts {
		weights := logits.Softmax(ctx)
		up := l.FFNUpExps.Forward(ctx, hiddenStates)
		gate := l.FFNGateExps.Forward(ctx, hiddenStates)
		up = up.Reshape(ctx, opts.hiddenSize, opts.numExperts, 1)
		gate = gate.Reshape(ctx, opts.hiddenSize, opts.numExperts, 1)
		activated := up.Sigmoid(ctx).Mul(ctx, gate)
		down := l.FFNDownExps.Forward(ctx, activated)
		down = down.Reshape(ctx, opts.hiddenSize, hiddenStates.Dim(1), hiddenStates.Dim(2))
		return down.Mul(ctx, weights)
	}

	if l.FFNGateUpExps != nil && l.FFNDownExps != nil {
		gateUp := l.FFNGateUpExps.Forward(ctx, hiddenStates)
		gateUp = gateUp.Reshape(ctx, opts.hiddenSize, opts.numExperts*2, hiddenStates.Dim(1))

		gate := gateUp.Slice(ctx, 1, 0, opts.numExperts, 1)
		up := gateUp.Slice(ctx, 1, opts.numExperts, opts.numExperts*2, 1)

		gate = gate.Sigmoid(ctx)
		up = up.GELU(ctx, up)

		activated := gate.Mul(ctx, up)
		activated = activated.Reshape(ctx, opts.hiddenSize, opts.numExperts, hiddenStates.Dim(1))

		down := l.FFNDownExps.Forward(ctx, activated)
		down = down.Reshape(ctx, opts.hiddenSize, hiddenStates.Dim(1), hiddenStates.Dim(2))

		weights := logits.Softmax(ctx)
		return down.Mul(ctx, weights)
	}

	return hiddenStates
}

type TextAttention struct {
	Query     *nn.Linear  `gguf:"attn_q"`
	QueryNorm *nn.RMSNorm `gguf:"attn_q_norm"`
	Key       *nn.Linear  `gguf:"attn_k"`
	KeyNorm   *nn.RMSNorm `gguf:"attn_k_norm"`
	Value     *nn.Linear  `gguf:"attn_v"`
	Output    *nn.Linear  `gguf:"attn_output"`
}

func (attn TextAttention) Forward(ctx ml.Context, hiddenStates, positions ml.Tensor, cache kvcache.Cache, sharedKV bool, ropeBase float32, opts *TextOptions) ml.Tensor {
	batchSize := hiddenStates.Dim(1)

	query := attn.Query.Forward(ctx, hiddenStates)
	query = query.Reshape(ctx, opts.headDim(), opts.numHeads, batchSize)
	query = attn.QueryNorm.Forward(ctx, query, opts.eps)
	query = opts.applyRotaryPositionEmbeddings(ctx, query, positions, ropeBase)

	var key, value ml.Tensor
	if !sharedKV {
		key = attn.Key.Forward(ctx, hiddenStates)
		key = key.Reshape(ctx, opts.headDim(), opts.numKVHeads, batchSize)
		if attn.KeyNorm != nil {
			key = attn.KeyNorm.Forward(ctx, key, opts.eps)
		}
		key = opts.applyRotaryPositionEmbeddings(ctx, key, positions, ropeBase)

		value = attn.Value.Forward(ctx, hiddenStates)
		value = value.Reshape(ctx, opts.headDim(), opts.numKVHeads, batchSize)
		value = value.RMSNorm(ctx, nil, opts.eps)
	}

	attention := nn.Attention(ctx, query, key, value, 1.0, cache)
	attention = attention.Reshape(ctx, attention.Dim(0)*attention.Dim(1), batchSize)
	return attn.Output.Forward(ctx, attention)
}

type TextMLP struct {
	Gate *nn.Linear `gguf:"ffn_gate"`
	Up   *nn.Linear `gguf:"ffn_up"`
	Down *nn.Linear `gguf:"ffn_down"`
}

func (mlp TextMLP) Forward(ctx ml.Context, hiddenStates ml.Tensor) ml.Tensor {
	upStates := mlp.Up.Forward(ctx, hiddenStates)
	hiddenStates = mlp.Gate.Forward(ctx, hiddenStates)
	hiddenStates = hiddenStates.GELU(ctx, upStates)
	return mlp.Down.Forward(ctx, hiddenStates)
}

type TextOptions struct {
	hiddenLayers            int
	hiddenSize              int
	hiddenSizePerLayerInput int
	numHeads, numKVHeads    int
	keyLength, valueLength  int
	sharedKeyValueLayers    int
	numExperts              int

	eps           float32
	ropeBase      float32
	ropeBaseLocal float32
	ropeScale     float32

	slidingWindowPattern    []bool
	activationSparsityScale []float32

	attnLogitSoftcap  float32
	finalLogitSoftcap float32
}

func (o *TextOptions) headDim() int {
	return cmp.Or(o.keyLength, o.valueLength, o.hiddenSize/o.numHeads)
}

func (o *TextOptions) isLocal(i int) bool {
	return o.slidingWindowPattern[i]
}

func (o TextOptions) applyRotaryPositionEmbeddings(ctx ml.Context, t, p ml.Tensor, base float32) ml.Tensor {
	return nn.RoPE(ctx, t, p, o.headDim(), base, 1./o.ropeScale, rope.WithTypeNeoX())
}

func newTextModel(c fs.Config) *TextModel {
	return &TextModel{
		TextLayers: make([]TextLayer, c.Uint("block_count")),
		TextOptions: TextOptions{
			hiddenLayers:            int(c.Uint("block_count")),
			hiddenSize:              int(c.Uint("embedding_length")),
			hiddenSizePerLayerInput: int(c.Uint("embedding_length_per_layer_input")),
			numHeads:                int(c.Uint("attention.head_count")),
			numKVHeads:              int(c.Uint("attention.head_count_kv")),
			keyLength:               int(c.Uint("attention.key_length")),
			valueLength:             int(c.Uint("attention.value_length")),
			sharedKeyValueLayers:    int(c.Uint("attention.shared_kv_layers")),

			numExperts: int(c.Uint("expert_count")),

			eps:           c.Float("attention.layer_norm_rms_epsilon", 1e-06),
			ropeBase:      c.Float("rope.freq_base", 1_000_000),
			ropeBaseLocal: c.Float("rope.freq_base_swa", 10_000),
			ropeScale:     c.Float("rope.scaling.factor", 1.0),

			slidingWindowPattern:    c.Bools("attention.sliding_window_pattern"),
			activationSparsityScale: c.Floats("activation_sparsity_scale"),

			attnLogitSoftcap:  c.Float("attn_logit_softcapping", 0),
			finalLogitSoftcap: c.Float("final_logit_softcapping", 0),
		},
	}
}
