#!/bin/bash
cp out/main.wasm ../sqrew.github.io/carp-voxel-engine/
cp out/index.js ../sqrew.github.io/carp-voxel-engine/
cd ../sqrew.github.io
git add .
git commit -m "Fix entity despawn lifetime leak (AppEvent handle generation mismatch)"
git push
