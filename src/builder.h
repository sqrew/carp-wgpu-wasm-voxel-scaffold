
#ifndef BUILDER_H
#define BUILDER_H

#include <webgpu/webgpu.h>

typedef struct {
    WGPUBindGroupEntry entries[16];
    int count;
} BindGroupBuilder;

#endif
