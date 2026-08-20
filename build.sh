#!/usr/bin/env bash
# build.sh -- Build Carp project for WebAssembly / WebGPU

CARP_FORK_DIR="/home/sqrew/Desktop/Carp-fork"
PROJECT_DIR="/home/sqrew/Desktop/carp-wgpu-wasm-voxel-scaffold"
EMSDK_DIR="/home/sqrew/Programs/emsdk"

# Exit on error
set -e

echo "=== 1. Generating C code from Carp ==="
if [ ! -d "$CARP_FORK_DIR" ]; then
    echo "Error: Carp-fork directory not found at $CARP_FORK_DIR"
    exit 1
fi

cd "$CARP_FORK_DIR"
./scripts/carp.sh -b --generate-only "$PROJECT_DIR/src/main.carp"

cd "$PROJECT_DIR"
cp "$CARP_FORK_DIR/out/main.c" "$PROJECT_DIR/src/main.c"
echo "Generated src/main.c successfully."

echo "=== 2. Compiling C code to WebAssembly ==="
if [ ! -f "$EMSDK_DIR/emsdk_env.sh" ]; then
    echo "Error: Emscripten SDK not found at $EMSDK_DIR"
    exit 1
fi

# Load Emscripten environment
source "$EMSDK_DIR/emsdk_env.sh"

echo "Compiling src/main.c to src/main.o..."
emcc -c src/main.c -I"$CARP_FORK_DIR/core/" --use-port=emdawnwebgpu -sUSE_GLFW=3 -sASYNCIFY=1 -sALLOW_MEMORY_GROWTH=1 -o src/main.o

echo "Linking src/main.o to index.html..."
em++ src/main.o --use-port=emdawnwebgpu -sUSE_GLFW=3 -sASYNCIFY=1 -sALLOW_MEMORY_GROWTH=1 -o index.html

echo "=== Build Succeeded! ==="
echo "To run the local web server, run: python3 -m http.server 8000"
echo "Then visit http://localhost:8000 in a browser with WebGPU enabled."
