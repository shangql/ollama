package convert

import (
	"slices"
	"strings"

	"github.com/ollama/ollama/fs/ggml"
	"gonum.org/v1/gonum/stat/distuv"
)

type gemma4Model struct {
	ModelParameters

	TextModel struct {
		ActivationSparsityPattern []float32 `json:"activation_sparsity_pattern"`
		HeadDim                   uint32    `json:"head_dim"`
		HiddenSize                uint32    `json:"hidden_size"`
		HiddenSizePerLayerInput   uint32    `json:"hidden_size_per_layer_input"`
		IntermediateSize          uint32    `json:"intermediate_size"`
		MaxPositionEmbeddings     uint32    `json:"max_position_embeddings"`
		NumAttentionHeads         uint32    `json:"num_attention_heads"`
		NumHiddenLayers           uint32    `json:"num_hidden_layers"`
		NumKeyValueHeads          uint32    `json:"num_key_value_heads"`
		NumKVSharedLayers         uint32    `json:"num_kv_shared_layers"`
		RMSNormEPS                float32   `json:"rms_norm_eps"`
		RopeLocalBaseFreq         float32   `json:"rope_local_base_freq"`
		RopeTheta                 float32   `json:"rope_theta"`
		SlidingWindow             uint32    `json:"sliding_window"`
		LayerTypes                []string  `json:"layer_types"`
		ExpertCount               uint32    `json:"expert_count"`
		ExpertFeedForwardLength   uint32    `json:"expert_feed_forward_length"`
	} `json:"text_config"`
}

func (m *gemma4Model) KV(t *Tokenizer) KV {
	kv := m.ModelParameters.KV(t)
	kv["general.architecture"] = "gemma4"
	kv["gemma4.activation_sparsity_scale"] = slices.Collect(func(yield func(float32) bool) {
		norm := distuv.Normal{Mu: 0, Sigma: 1}
		for _, v := range m.TextModel.ActivationSparsityPattern {
			if !yield(float32(norm.Quantile(float64(v)))) {
				break
			}
		}
	})
	kv["gemma4.attention.head_count_kv"] = m.TextModel.NumKeyValueHeads
	kv["gemma4.attention.head_count"] = m.TextModel.NumAttentionHeads
	kv["gemma4.attention.layer_norm_rms_epsilon"] = m.TextModel.RMSNormEPS
	kv["gemma4.attention.sliding_window"] = m.TextModel.SlidingWindow
	kv["gemma4.attention.sliding_window_pattern"] = slices.Collect(func(yield func(bool) bool) {
		for _, t := range m.TextModel.LayerTypes {
			if !yield(t == "sliding_attention") {
				break
			}
		}
	})
	kv["gemma4.attention.shared_kv_layers"] = m.TextModel.NumKVSharedLayers
	kv["gemma4.block_count"] = m.TextModel.NumHiddenLayers
	kv["gemma4.context_length"] = m.TextModel.MaxPositionEmbeddings
	kv["gemma4.embedding_length_per_layer_input"] = m.TextModel.HiddenSizePerLayerInput
	kv["gemma4.embedding_length"] = m.TextModel.HiddenSize
	kv["gemma4.feed_forward_length"] = m.TextModel.IntermediateSize
	kv["gemma4.head_dim"] = m.TextModel.HeadDim
	kv["gemma4.rope.freq_base_swa"] = m.TextModel.RopeLocalBaseFreq
	kv["gemma4.rope.freq_base"] = m.TextModel.RopeTheta
	kv["gemma4.expert_count"] = m.TextModel.ExpertCount
	kv["gemma4.expert_feed_forward_length"] = m.TextModel.ExpertFeedForwardLength
	return kv
}

func (m *gemma4Model) Tensors(ts []Tensor) []*ggml.Tensor {
	out, ts := mergeTensors(ts,
		merge{"altup_proj.*.weight", "altup_proj.weight"},
		merge{"altup_unembd_proj.*.weight", "altup_unembd_proj.weight"},
	)

	for _, t := range ts {
		switch {
		case strings.Contains(t.Name(), "audio_tower"),
			strings.Contains(t.Name(), "embed_audio"),
			strings.Contains(t.Name(), "vision_tower"),
			strings.Contains(t.Name(), "embed_vision"):
			// TODO: handle audio and vision towers
			continue
		}

		out = append(out, &ggml.Tensor{
			Name:     t.Name(),
			Kind:     t.Kind(),
			Shape:    t.Shape(),
			WriterTo: t,
		})
	}

	return out
}

func (m *gemma4Model) Replacements() []string {
	return []string{
		"model.language_model.embed_tokens_per_layer", "per_layer_token_embd",
		"model.language_model.embed_tokens", "token_embd",
		"model.language_model.per_layer_model_projection", "per_layer_model_proj",
		"model.language_model.per_layer_projection_norm", "per_layer_proj_norm",
		"model.language_model.norm", "output_norm",
		"model.language_model.layers", "blk",

		"input_layernorm", "attn_norm",
		"self_attn.q_proj", "attn_q",
		"self_attn.q_norm", "attn_q_norm",
		"self_attn.k_proj", "attn_k",
		"self_attn.k_norm", "attn_k_norm",
		"self_attn.v_proj", "attn_v",
		"self_attn.o_proj", "attn_output",
		"post_attention_layernorm", "post_attention_norm",
		"pre_feedforward_layernorm", "ffn_norm",
		"mlp.gate_proj", "ffn_gate",
		"mlp.up_proj", "ffn_up",
		"mlp.down_proj", "ffn_down",
		"post_feedforward_layernorm", "post_ffw_norm",
		"per_layer_input_gate", "inp_gate",
		"per_layer_projection", "proj",
		"post_per_layer_input_norm", "post_norm",
		"modality_router", "router",
		"ffn_gate_inp_scale", "ffn_gate_inp.scale",
		"ffn_pre_norm_2", "ffn_pre_norm_2",
		"ffn_post_norm_1", "ffn_post_norm_1",
		"ffn_post_norm_2", "ffn_post_norm_2",
		"ffn_gate_exps", "ffn_gate_exps",
		"ffn_up_exps", "ffn_up_exps",
		"ffn_down_exps", "ffn_down_exps",
		"ffn_gate_up_exps", "ffn_gate_up_exps",
		"layer_out_scale", "layer_out_scale",
	}
}
