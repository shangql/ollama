#!/bin/bash
# Ollama 启动脚本（Intel Mac AMDGPU + MoltenVK）
#
# 使用方法：
#   ./start.sh          # 启动服务器
#   ./start.sh run <模型名>  # 直接运行模型

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export OLLAMA_VULKAN=1
# 修复 MoltenVK + AMD GPU fp16 精度 bug 导致的乱码
# 强制使用 fp32 计算，代价：性能下降约 15-20%
export GGML_VK_DISABLE_F16=1
# 禁用 Flash Attention（着色器内部使用 fp16，绕过 GGML_VK_DISABLE_F16）
# llama3.1:8b 等模型需要此变量才能正常输出
export OLLAMA_FLASH_ATTENTION=false

cd "$SCRIPT_DIR"

if [ "${1:-}" = "run" ]; then
    shift
    ./bin/ollama run "$@"
else
    echo "=== Ollama 服务器启动 ==="
    echo "OLLAMA_VULKAN=1 GGML_VK_DISABLE_F16=1 OLLAMA_FLASH_ATTENTION=false"
    echo "访问: http://localhost:11434"
    echo "========================="
    ./bin/ollama serve
fi
