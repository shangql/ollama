#!/bin/bash
#
# build_darwin_vulkan_opencode.sh - 使用 CMake 构建 Ollama（含 MoltenVK Vulkan 支持）
#
# 通过 CMake 构建系统编译 Go 主服务器（ollama_server）、runner 子进程（ollama_runner）
# 以及 C++ 后端（CPU + Vulkan），输出到 dist/darwin-${ARCH}。
#
# 与 build_darwin_vulkan.sh 的区别：
#   - 使用 CMake Go 目标（ollama_server + ollama_runner）而非直接 go build
#   - 自动安装 Vulkan dylib 到 bin/（通过 install(FILES)）
#   - 支持 OLLAMA_VULKAN=1 运行时 GPU discovery
#
# 前置条件：
#   - CMake 3.21+
#   - Xcode Command Line Tools
#   - Go 1.22+
#   - brew install cmake shaderc glslang libomp
#
# 用法：
#   ./scripts/build_darwin_vulkan_opencode.sh              # 构建全部
#   ./scripts/build_darwin_vulkan_opencode.sh -a amd64     # 仅构建 amd64
#   ./scripts/build_darwin_vulkan_opencode.sh -a arm64     # 仅构建 arm64
#   ./scripts/build_darwin_vulkan_opencode.sh cpp          # 仅构建 C++ 后端
#   ./scripts/build_darwin_vulkan_opencode.sh go           # 仅构建 Go 二进制
#   ./scripts/build_darwin_vulkan_opencode.sh clean        # 清理构建目录
#

set -euo pipefail

# ── 项目根目录 ─────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# ── 版本信息 ───────────────────────────────────────────────────────────────────
export VERSION
VERSION="$(git describe --tags --first-parent --abbrev=7 --long --dirty --always 2>/dev/null | sed -e 's/^v//g')"
if [ -z "$VERSION" ]; then
    VERSION="0.0.0-opencode"
fi

# ── CGO 编译标志 ───────────────────────────────────────────────────────────────
export CGO_CFLAGS="-mmacosx-version-min=14.0"
export CGO_CXXFLAGS="-mmacosx-version-min=14.0"
export CGO_LDFLAGS="-mmacosx-version-min=14.0"
export CGO_ENABLED=1
export GOOS=darwin

# ── 默认参数 ───────────────────────────────────────────────────────────────────
ARCHS="amd64"
NCPU="$(sysctl -n hw.ncpu)"

# ── 辅助函数 ───────────────────────────────────────────────────────────────────
status() { echo >&2 ">>> $*"; }
error()  { echo >&2 "!!! 错误: $*"; exit 1; }

# Go 架构名 → CMake OSX_ARCHITECTURES 映射
goarch_to_cmake() {
    case "$1" in
        amd64) echo "x86_64" ;;
        arm64) echo "arm64" ;;
        *)     echo "$1" ;;
    esac
}

# ── 解析参数 ───────────────────────────────────────────────────────────────────
CMD=""
while getopts "a:h" OPTION; do
    case $OPTION in
        a) ARCHS="$OPTARG" ;;
        h)
            echo "用法: $(basename "$0") [-a arch] [cpp|go|clean]"
            echo "  -a arch    架构: amd64, arm64 (默认: amd64)"
            echo "  cpp        仅构建 C++ 后端"
            echo "  go         仅构建 Go 二进制"
            echo "  clean      清理构建目录"
            exit 0
            ;;
        *) exit 1 ;;
    esac
done
shift $(( OPTIND - 1 ))

if [ "$#" -gt 0 ]; then
    CMD="$1"
fi

mkdir -p dist

# ── 阶段 1: 构建 C++ 后端（CPU + Vulkan） ────────────────────────────────────
build_cpp() {
    for ARCH in $ARCHS; do
        status "=== 构建 C++ 后端 (darwin-${ARCH}) ==="

        OSXARCH="$(goarch_to_cmake "$ARCH")"
        INSTALL_PREFIX="${PROJECT_ROOT}/dist/darwin-${ARCH}"

        # ── 步骤 1a: 配置 MoltenVK preset（下载 SDK + 设置 Vulkan 路径） ──
        status "配置 MoltenVK (${ARCH})..."
        cmake --preset MoltenVK \
            -DCMAKE_OSX_ARCHITECTURES="$OSXARCH" \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

        # ── 步骤 1b: 配置 Go MoltenVK preset（含 Go 目标 + C++ 后端） ──
        status "配置 Go + MoltenVK (${ARCH})..."
        cmake --preset "Go MoltenVK" \
            -DCMAKE_OSX_ARCHITECTURES="$OSXARCH" \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

        # ── 步骤 1c: 构建所有目标 ──
        status "编译所有目标 (${ARCH})..."
        cmake --build build -j"$NCPU" \
            --target ggml-vulkan ollama_server ollama_runner

        # ── 步骤 1d: 安装到 dist/ ──
        # Go 组件包含: ollama, ollama-runner, libggml-vulkan.so,
        # libMoltenVK.dylib, libggml-base.*.dylib 及 CPU .so 后端
        status "安装到 ${INSTALL_PREFIX}..."
        cmake --install build --prefix "$INSTALL_PREFIX" --component Go

        status "C++ 后端 + Go 二进制已构建 (${ARCH})"
    done
}

# ── 阶段 2: 构建 Go 二进制（使用 CMake Go 目标） ────────────────────────────
build_go() {
    for ARCH in $ARCHS; do
        status "=== 构建 Go 二进制 (darwin-${ARCH}) ==="

        OSXARCH="$(goarch_to_cmake "$ARCH")"
        INSTALL_PREFIX="${PROJECT_ROOT}/dist/darwin-${ARCH}"

        # 确保 CMake 已配置
        if [ ! -f build/CMakeCache.txt ]; then
            status "CMake 未配置，先执行配置..."
            cmake --preset "Go MoltenVK" \
                -DCMAKE_OSX_ARCHITECTURES="$OSXARCH" \
                -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
        fi

        # 构建 Go 目标
        status "编译 Go 目标 (${ARCH})..."
        cmake --build build -j"$NCPU" \
            --target ollama_server ollama_runner

        # 安装 Go 组件
        status "安装 Go 二进制 (${ARCH})..."
        cmake --install build --prefix "$INSTALL_PREFIX" --component Go

        status "Go 二进制已构建 (${ARCH}) → ${INSTALL_PREFIX}/bin/"
    done
}

# ── 清理 ──────────────────────────────────────────────────────────────────────
do_clean() {
    status "清理构建目录..."
    rm -rf build/
    status "清理完成"
}

# ── 验证 ───────────────────────────────────────────────────────────────────────
verify() {
    for ARCH in $ARCHS; do
        INSTALL_PREFIX="${PROJECT_ROOT}/dist/darwin-${ARCH}"
        status "=== 验证 (darwin-${ARCH}) ==="

        # 检查关键文件
        [ -f "$INSTALL_PREFIX/bin/ollama" ]       || error "缺少 bin/ollama"
        [ -f "$INSTALL_PREFIX/bin/ollama-runner" ] || error "缺少 bin/ollama-runner"
        [ -f "$INSTALL_PREFIX/bin/libggml-vulkan.so" ] || error "缺少 bin/libggml-vulkan.so"
        [ -f "$INSTALL_PREFIX/bin/libMoltenVK.dylib" ] || error "缺少 bin/libMoltenVK.dylib"
        [ -f "$INSTALL_PREFIX/bin/libggml-base.0.0.0.dylib" ] || error "缺少 bin/libggml-base.0.0.0.dylib"

        # 检查符号链接
        [ -L "$INSTALL_PREFIX/bin/libggml-base.dylib" ] || error "缺少符号链接 libggml-base.dylib"
        [ -L "$INSTALL_PREFIX/bin/libggml-base.0.dylib" ] || error "缺少符号链接 libggml-base.0.dylib"

        # 检查架构
        FILE_INFO=$(file "$INSTALL_PREFIX/bin/ollama")
        status "ollama 架构: $FILE_INFO"

        # 检查版本
        VERSION_OUTPUT="$("$INSTALL_PREFIX/bin/ollama" --version 2>&1 || true)"
        status "版本: $VERSION_OUTPUT"

        status "✅ 验证通过 (${ARCH})"
    done
}

# ── 主流程 ─────────────────────────────────────────────────────────────────────
status "Ollama Vulkan 构建脚本 (OpenCode 版)"
status "版本: ${VERSION}"
status "架构: ${ARCHS}"
status "CPU 核心: ${NCPU}"
status ""

case "${CMD:-all}" in
    cpp)
        build_cpp
        verify
        ;;
    go)
        build_go
        verify
        ;;
    clean)
        do_clean
        ;;
    all)
        build_cpp
        status ""
        status "=== 构建完成，开始验证 ==="
        verify
        status ""
        status "🚀 运行方式:"
        status "  cd dist/darwin-amd64 && OLLAMA_VULKAN=1 ./bin/ollama serve"
        ;;
    *)
        error "未知命令: $CMD (可用: cpp, go, clean, all)"
        ;;
esac
