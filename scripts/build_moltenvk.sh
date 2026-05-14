#!/bin/sh
#
# build_moltenvk.sh - Build Ollama for macOS with MoltenVK (Vulkan→Metal)
#
# 使用 CMake 构建 C++ 后端，然后编译 Go 主程序。
# 支持 Intel Mac (amd64) 和 Apple Silicon (arm64)。
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION="$(git describe --tags --first-parent --abbrev=7 --long --dirty --always | sed -e 's/^v//g')"

echo "=== Ollama MoltenVK Build ==="
echo " VERSION: $VERSION"
echo " ROOT:   $PROJECT_ROOT"

# 默认构建 amd64（Intel Mac）
ARCHS="${ARCHS:-amd64}"

# macOS 最低版本
MACOS_MIN_VERSION="-mmacosx-version-min=14.0"
export CGO_CFLAGS="$MACOS_MIN_VERSION"
export CGO_CXXFLAGS="$MACOS_MIN_VERSION"
export CGO_LDFLAGS="$MACOS_MIN_VERSION"

# ── 辅助函数 ──────────────────────────────────────────────

goarch_to_cmake() {
    case "$1" in
        amd64) echo "x86_64" ;;
        arm64) echo "arm64" ;;
        *)     echo "$1" ;;
    esac
}

# ── Phase 1: 构建 C++ 后端 ─────────────────────────────────

build_cpp() {
    for ARCH in $ARCHS; do
        OSXARCH="$(goarch_to_cmake "$ARCH")"
        BUILD_DIR="$PROJECT_ROOT/build/darwin-$ARCH"
        INSTALL_PREFIX="$PROJECT_ROOT/dist/darwin-$ARCH"

        echo ""
        echo "=== [Phase 1] C++ Backend: darwin-$ARCH ==="

        # 清理旧构建
        rm -rf "$BUILD_DIR"

        mkdir -p "$BUILD_DIR"
        mkdir -p "$INSTALL_PREFIX/lib"

        # 配置 CPU 后端
        echo "[1/3] Configure CPU backend ($ARCH)..."
        cmake -B "$BUILD_DIR" \
            -DCMAKE_OSX_ARCHITECTURES="$OSXARCH" \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=11.3 \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

        # 构建 CPU 后端
        echo "[2/3] Build CPU backend ($ARCH)..."
        cmake --build "$BUILD_DIR" -j"$(sysctl -n hw.ncpu)"

        # 安装 CPU 后端
        echo "[3/3] Install CPU backend ($ARCH)..."
        cmake --install "$BUILD_DIR" --component CPU

        # 配置 Vulkan 后端（使用 MoltenVK preset）
        if cmake --preset MoltenVK 2>/dev/null; then
            echo "[Vulkan] Configure MoltenVK ($ARCH)..."
            cmake --preset MoltenVK \
                -DCMAKE_OSX_ARCHITECTURES="$OSXARCH" \
                -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

            # MoltenVK 配置输出到 build/darwin-$ARCH/ 目录
            cmake --build "build/darwin-$ARCH" -j"$(sysctl -n hw.ncpu)"

            echo "[Vulkan] Install ($ARCH)..."
            cmake --install "build/darwin-$ARCH" --component Vulkan
        else
            echo "[Vulkan] Skipping - MoltenVK preset not available"
        fi

        echo "[OK] C++ backends for darwin-$ARCH"
    done
}

# ── Phase 2: 构建 Go 主程序 ─────────────────────────────────

build_go() {
    for ARCH in $ARCHS; do
        echo ""
        echo "=== [Phase 2] Go Binary: darwin-$ARCH ==="

        INSTALL_PREFIX="$PROJECT_ROOT/dist/darwin-$ARCH/"

        # 设置库搜索路径
        export OLLAMA_LIBRARY_PATH="$INSTALL_PREFIX/lib"

        GOOS=darwin GOARCH="$ARCH" CGO_ENABLED=1 go build \
            -ldflags="-w -s -X=github.com/ollama/ollama/version.Version=${VERSION}" \
            -o "$INSTALL_PREFIX" .

        echo "[OK] Go binary: $INSTALL_PREFIX"
    done
}

# ── Phase 3: 创建通用二进制 ─────────────────────────────────

sign_darwin() {
    echo ""
    echo "=== [Phase 3] Create Universal Binary ==="

    mkdir -p dist/darwin

    # 合并 amd64 + arm64
    if [ -f dist/darwin-amd64/ollama ] && [ -f dist/darwin-arm64/ollama ]; then
        lipo -create -output dist/darwin/ollama \
            dist/darwin-amd64/ollama \
            dist/darwin-arm64/ollama
    elif [ -f dist/darwin-amd64/ollama ]; then
        cp dist/darwin-amd64/ollama dist/darwin/ollama
    fi

    chmod +x dist/darwin/ollama

    # 打包
    echo "[OK] Universal binary created"
    ls -lh dist/darwin/ollama
}

# ── 主入口 ─────────────────────────────────────────────────

case "${1:-build}" in
    build)
        build_cpp
        build_go
        sign_darwin
        ;;
    cpp)
        build_cpp
        ;;
    go)
        build_go
        ;;
    sign)
        sign_darwin
        ;;
    *)
        echo "Usage: $0 [build|cpp|go|sign]"
        exit 1
        ;;
esac