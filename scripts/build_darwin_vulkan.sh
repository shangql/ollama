#!/bin/sh
#
# build_darwin_vulkan.sh - Build Ollama for macOS with MoltenVK (Vulkan→Metal)
#
# Builds Ollama with experimental Vulkan support on macOS via MoltenVK,
# enabling AMD GPU acceleration on Intel Macs.
#
# Prerequisites:
#   - CMake 3.21+
#   - Xcode Command Line Tools
#   - Go 1.22+
#
# Usage:
#   ./scripts/build_darwin_vulkan.sh              # Build everything
#   ./scripts/build_darwin_vulkan.sh build        # Build binaries only
#   ./scripts/build_darwin_vulkan.sh -a arm64     # Build for arm64 only
#   ./scripts/build_darwin_vulkan.sh -a amd64     # Build for amd64 only
#

VOL_NAME="${VOL_NAME:-Ollama}"
export VERSION
VERSION="$(git describe --tags --first-parent --abbrev=7 --long --dirty --always | sed -e 's/^v//g')"
export CGO_CFLAGS="-mmacosx-version-min=14.0"
export CGO_CXXFLAGS="-mmacosx-version-min=14.0"
export CGO_LDFLAGS="-mmacosx-version-min=14.0"

set -e

status() { echo >&2 ">>> $*"; }
usage() {
    echo "usage: $(basename "$0") [-a arch] [build [app]]"
    exit 1
}

mkdir -p dist

ARCHS="arm64 amd64"
while getopts "a:h" OPTION; do
    case $OPTION in
        a) ARCHS="$OPTARG" ;;
        h) usage ;;
    esac
done
shift $(( OPTIND - 1 ))

# Map Go arch to CMake OSX arch
goarch_to_cmake() {
    case "$1" in
        amd64) echo "x86_64" ;;
        arm64) echo "arm64" ;;
        *)     echo "$1" ;;
    esac
}

# Phase 1: Build C++ backends with CMake (must run before go build)
build_cpp() {
    for ARCH in $ARCHS; do
        status "=== Building C++ backends for darwin-${ARCH} ==="

        OSXARCH="$(goarch_to_cmake "$ARCH")"
        INSTALL_PREFIX="${PWD}/dist/darwin-${ARCH}"
        BUILD_DIR="build/darwin-${ARCH}"
        NCPU="$(sysctl -n hw.ncpu)"

        rm -rf "$BUILD_DIR"

        # Step 1a: Configure MoltenVK preset
        # This downloads the MoltenVK SDK and sets up Vulkan include/library paths
        status "Configuring MoltenVK (${ARCH})..."
        cmake --preset MoltenVK \
            -DCMAKE_OSX_ARCHITECTURES="$OSXARCH" \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

        # Step 1b: Configure CPU backend
        status "Configuring CPU backend (${ARCH})..."
        cmake -B "$BUILD_DIR" \
            -DCMAKE_OSX_ARCHITECTURES="$OSXARCH" \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=11.3 \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

        # Step 1c: Build + install CPU backend
        # On x86_64 macOS, GGML_CPU_ALL_VARIANTS is ON, creating per-variant
        # targets (ggml-cpu-x64, ggml-cpu-haswell, etc.) instead of a single
        # ggml-cpu target. Build all targets in the directory.
        status "Building CPU backend (${ARCH})..."
        cmake --build "$BUILD_DIR" -j"$NCPU"
        cmake --install "$BUILD_DIR" --component CPU

        # Step 1d: Build + install Vulkan backend (MoltenVK preset)
        status "Building Vulkan backend (${ARCH})..."
        cmake --build --preset MoltenVK -j"$NCPU"
        cmake --install build --component Vulkan

        status "C++ backends built for ${ARCH}"
    done
}

# Phase 2: Build Go binary (links against C++ backends from Phase 1)
build_go() {
    for ARCH in $ARCHS; do
        status "=== Building Go binary for darwin-${ARCH} ==="

        INSTALL_PREFIX="dist/darwin-${ARCH}/"
        GOOS=darwin GOARCH="$ARCH" CGO_ENABLED=1 go build \
            -ldflags="-w -s -X=github.com/ollama/ollama/version.Version=${VERSION} -X=github.com/ollama/ollama/server.mode=release" \
            -o "$INSTALL_PREFIX" .

        status "Go binary built for ${ARCH} -> ${INSTALL_PREFIX}ollama"
    done
}

# Phase 3: Create universal binary + tarball
sign_darwin() {
    status "Creating universal binary..."
    mkdir -p dist/darwin
    lipo -create -output dist/darwin/ollama dist/darwin-*/ollama
    chmod +x dist/darwin/ollama

    if [ -n "$APPLE_IDENTITY" ]; then
        for F in dist/darwin/ollama dist/darwin-amd64/lib/ollama/*; do
            codesign -f --timestamp -s "$APPLE_IDENTITY" -identifier ai.ollama.ollama -options=runtime "$F"
        done
        TEMP="$(mktemp -u).zip"
        ditto -c -k --keepParent dist/darwin/ollama "$TEMP"
        xcrun notarytool submit "$TEMP" -wait -timeout 10m -apple-id "$APPLE_ID" -password "$APPLE_PASSWORD" -team-id "$APPLE_TEAM_ID"
        rm -f "$TEMP"
    fi

    status "Creating tarball..."
    tar -cf dist/ollama-darwin.tar -strip-components 2 dist/darwin/ollama
    tar -rf dist/ollama-darwin.tar -strip-components 4 dist/darwin-amd64/lib/
    gzip -9vc < dist/ollama-darwin.tar > dist/ollama-darwin.tgz
}

# Phase 4: Build macOS .app bundle
build_app() {
    if ! command -v npm > /dev/null 2>&1; then
        echo "npm is not installed. Install Node.js first: https://nodejs.org/"
        exit 1
    fi
    if ! command -v tsc > /dev/null 2>&1; then
        echo "Installing TypeScript compiler..."
        npm install -g typescript
    fi

    cd app/ui/app
    npm install
    npm run build
    cd ../../..

    rm -rf dist/Ollama.app
    cp -a ./app/darwin/Ollama.app dist/Ollama.app
    touch dist/Ollama.app

    go clean -cache
    GOARCH=amd64 CGO_ENABLED=1 GOOS=darwin go build -o dist/darwin-app-amd64 -ldflags="-s -w -X=github.com/ollama/ollama/app/version.Version=${VERSION}" ./app/cmd/app
    GOARCH=arm64 CGO_ENABLED=1 GOOS=darwin go build -o dist/darwin-app-arm64 -ldflags="-s -w -X=github.com/ollama/ollama/app/version.Version=${VERSION}" ./app/cmd/app
    mkdir -p dist/Ollama.app/Contents/MacOS
    lipo -create -output dist/Ollama.app/Contents/MacOS/Ollama dist/darwin-app-amd64 dist/darwin-app-arm64
    rm -f dist/darwin-app-amd64 dist/darwin-app-arm64

    # Mock Squirrel.framework
    mkdir -p dist/Ollama.app/Contents/Frameworks/Squirrel.framework/Versions/A/Resources/
    cp -a dist/Ollama.app/Contents/MacOS/Ollama dist/Ollama.app/Contents/Frameworks/Squirrel.framework/Versions/A/Squirrel
    ln -s ../Squirrel dist/Ollama.app/Contents/Frameworks/Squirrel.framework/Versions/A/Resources/ShipIt
    cp -a ./app/cmd/squirrel/Info.plist dist/Ollama.app/Contents/Frameworks/Squirrel.framework/Versions/A/Resources/Info.plist
    ln -s A dist/Ollama.app/Contents/Frameworks/Squirrel.framework/Versions/Current
    ln -s Versions/Current/Resources dist/Ollama.app/Contents/Frameworks/Squirrel.framework/Resources
    ln -s Versions/Current/Squirrel dist/Ollama.app/Contents/Frameworks/Squirrel.framework/Squirrel

    plutil -replace CFBundleShortVersionString -string "$VERSION" dist/Ollama.app/Contents/Info.plist
    plutil -replace CFBundleVersion -string "$VERSION" dist/Ollama.app/Contents/Info.plist

    # Install binaries + libraries into app bundle
    mkdir -p dist/Ollama.app/Contents/Resources
    RES="dist/Ollama.app/Contents/Resources"
    if [ -d dist/darwin-amd64 ]; then
        lipo -create -output "$RES/ollama" dist/darwin-amd64/ollama dist/darwin-arm64/ollama
        cp -a dist/darwin-amd64/lib/ollama/. "$RES/"
    else
        cp -a dist/darwin/ollama "$RES/ollama"
        if [ -d dist/darwin/lib/ollama ]; then
            cp -a dist/darwin/lib/ollama/. "$RES/"
        else
            cp dist/darwin/*.so dist/darwin/*.dylib "$RES/"
        fi
    fi
    if [ -d "$RES/vulkan" ]; then
        cp -a "$RES/vulkan/." "$RES/"
        rm -rf "$RES/vulkan"
    fi
    chmod a+x "$RES/ollama"

    if [ -n "$APPLE_IDENTITY" ]; then
        codesign -f -timestamp -s "$APPLE_IDENTITY" -identifier ai.ollama.ollama -options=runtime "$RES/ollama"
        for lib in "$RES"/*.so "$RES"/*.dylib; do
            [ -e "$lib" ] || continue
            codesign -f -timestamp -s "$APPLE_IDENTITY" -identifier ai.ollama.ollama -options=runtime "$lib"
        done
        codesign -f -timestamp -s "$APPLE_IDENTITY" -identifier com.electron.ollama -deep -options=runtime dist/Ollama.app
    fi

    ditto -c -k --keepParent dist/Ollama.app dist/Ollama-darwin.zip

    (cd "$RES"; tar -cf - ollama *.so *.dylib) | gzip -9vc > dist/ollama-darwin.tgz

    if [ -n "$APPLE_IDENTITY" ]; then
        rm -rf dist/OllamaDisk
        mkdir -p dist/OllamaDisk
        cp -a dist/Ollama.app dist/OllamaDisk/
        xcrun notarytool submit dist/Ollama-darwin.zip -wait -timeout 10m -apple-id "$APPLE_ID" -password "$APPLE_PASSWORD" -team-id "$APPLE_TEAM_ID"
        xcrun stapler staple dist/Ollama.app
        rm -rf dist/OllamaDisk
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
# Correct build order:
#   1. build_cpp  — CMake compiles C++ backends → .dylib files
#   2. build_go   — go build links Go + C++ .dylib files
#   3. sign_darwin — lipo + tarball
#   4. build_app  — .app bundle

if [ "$#" -eq 0 ]; then
    build_cpp
    build_go
    sign_darwin
    build_app
    exit 0
fi

for CMD in "$@"; do
    case $CMD in
        build) build_cpp; build_go ;;
        cpp)   build_cpp ;;
        go)    build_go ;;
        sign)  sign_darwin ;;
        app)   build_app ;;
        *)     usage ;;
    esac
done
