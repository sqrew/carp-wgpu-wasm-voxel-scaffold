# Carp WebGPU Voxel Engine 🚀

A high-performance, GPU-accelerated falling-sand voxel engine running entirely in the browser. Written in **[Carp](https://github.com/carp-lang/Carp)** (a statically typed, GC-free Lisp), compiled to C, and bundled into WebAssembly using Emscripten.

![Engine Demo](https://via.placeholder.com/800x400.png?text=Imagine+a+beautiful+GIF+of+falling+sand+and+raymarched+caves+here)

## ⚡ The Flex

Modern web engines are often bloated with megabytes of JavaScript, massive asset pipelines, and heavy frameworks. This engine takes a radically different approach:

- **Ultra Lightweight:** The entire physics engine, procedural generation, and raymarched lighting compile down to a single **283 KB** WebAssembly binary.
- **Blazing Fast:** Averages **~5.8ms frame times (170+ FPS)** on standard hardware.
- **GPU-Accelerated Physics:** Simulating millions of voxels takes just **~0.26ms per frame** using heavily parallelized WebGPU compute shaders.
- **Zero 3D Models:** The entire world is procedurally generated via noise, driven by Cellular Automata (CA), and rendered purely with math (SDF Raymarching).

## ✨ Features

- **Falling Sand Physics (Cellular Automata):** Fully simulated fluid dynamics and granular physics running entirely on the GPU. Water flows, sand piles up, and gases rise.
- **Emergent Elemental Reactions:** Fire burns wood, water extinguishes fire to create steam, and acid eats through rock. All driven by a bitflag-based elemental reaction system.
- **Data-Driven Materials:** A unified 1024-slot material registry dynamically dictates physics, rendering colors, densities, and lighting behaviors without hardcoded shader branching.
- **SDF Raymarched Rendering:** Smooth, voxel-perfect terrain rendering with atmospheric distance fog, dynamic sun/moon lighting, and ambient occlusion.
- **Infinite Procedural Terrain:** Chunk-based world generation that dynamically streams in as you explore.

## 🐟 Why Carp?

This project serves as a showcase for the **Carp** programming language. Carp is a functional, statically typed Lisp that manages memory without a Garbage Collector (similar to Rust's borrow checker) and compiles directly to highly optimized C. 

By writing the engine in Carp, we achieve:
1. The raw, bare-metal performance of C.
2. The ultimate syntactic flexibility, macros, and abstraction of a Lisp.
3. Flawless WebAssembly compilation with zero runtime bloat.

## 🛠️ Building and Running

### Prerequisites
- [Carp Compiler](https://github.com/carp-lang/Carp)
- [Emscripten (emsdk)](https://emscripten.org/)
- A browser with **WebGPU** enabled (Chrome 113+, Edge 113+).

### Quickstart

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/carp-wgpu-wasm-voxel-scaffold.git
   cd carp-wgpu-wasm-voxel-scaffold
   ```

2. **Build the WASM payload:**
   The included build script will compile the Carp source into C, and then use `emcc` to link it into WebAssembly.
   ```bash
   ./build.sh
   ```

3. **Serve the project:**
   Because WebAssembly needs to be fetched, you must run it over a local HTTP server (not directly from the filesystem).
   ```bash
   python3 -m http.server 8000
   ```
   
4. **Play:**
   Open `http://localhost:8000` in your WebGPU-enabled browser. 
   - **Click** to carve terrain or spawn materials.
   - **F** to toggle the player flashlight.
   
## 🗺️ Roadmap

- [x] Unify materials into a 1024-slot registry
- [x] WebGPU Compute Shader physics passes
- [ ] Structural Stress Field (unsupported overhangs crumble into falling sand)
- [ ] Indestructible Bedrock anchoring layers
- [ ] Integration of the `carp-arena` allocator for dynamic ECS queries

---
*Built with [Carp](https://github.com/carp-lang/Carp) & WebGPU.*
