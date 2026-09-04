#pragma once
#include <webgpu/webgpu.h>
#include <string.h>
#include <stdbool.h>

static float latest_hit_pos[4] = {0.0f, 0.0f, 0.0f, 0.0f};
static bool is_mapping = false;

static void buffer_map_callback(WGPUMapAsyncStatus status, WGPUStringView message, void* userdata1, void* userdata2) {
    is_mapping = false; printf("Map callback fired with status: %d\n", status); printf("Map callback fired with status: %d\n", status);
    if (status == WGPUMapAsyncStatus_Success) {
        WGPUBuffer buffer = (WGPUBuffer)userdata1;
        const void* mapped = wgpuBufferGetConstMappedRange(buffer, 0, 16);
        if (mapped) {
            printf("MAPPED OK!\n");
            memcpy(latest_hit_pos, mapped, 16); printf("Hit callback: %f, %f, %f, %f\n", latest_hit_pos[0], latest_hit_pos[1], latest_hit_pos[2], latest_hit_pos[3]);
        }
        wgpuBufferUnmap(buffer);
    }
}

static void gpu_readback_hit_pos_async(WGPUBuffer buffer) {
    if (is_mapping) return;
    is_mapping = true;
    
    WGPUBufferMapCallbackInfo cb_info = {
        .nextInChain = NULL,
        .mode = WGPUCallbackMode_AllowProcessEvents,
        .callback = buffer_map_callback,
        .userdata1 = (void*)buffer,
        .userdata2 = NULL
    };
    
    wgpuBufferMapAsync(buffer, WGPUMapMode_Read, 0, 16, cb_info);
}

static float gpu_readback_get_hit_x() { return latest_hit_pos[0]; }
static float gpu_readback_get_hit_y() { return latest_hit_pos[1]; }
static float gpu_readback_get_hit_z() { return latest_hit_pos[2]; }
static float gpu_readback_get_hit_w() { return latest_hit_pos[3]; }



static WGPUBuffer gpu_readback_create_map_buffer(WGPUContext* ctx) {
    WGPUBufferDescriptor desc = {
        .nextInChain = NULL,
        .label = "RaycastMapBuffer",
        .usage = WGPUBufferUsage_MapRead | WGPUBufferUsage_CopyDst,
        .size = 16,
        .mappedAtCreation = false
    };
    return wgpuDeviceCreateBuffer(ctx->device, &desc);
}
#include <stdio.h>

static bool gpu_readback_is_mapping() {
    return is_mapping;
}
static void gpu_readback_tick(WGPUContext* ctx) {
    wgpuInstanceProcessEvents(ctx->instance);
}

// --- Chunk Sync Readback ---
static bool is_mapping_chunk = false;
static float latest_chunk_data[32768 * 4];
static bool chunk_data_ready = false;

static void chunk_map_callback(WGPUMapAsyncStatus status, WGPUStringView message, void* userdata1, void* userdata2) {
    is_mapping_chunk = false;
    if (status == WGPUMapAsyncStatus_Success) {
        WGPUBuffer buffer = (WGPUBuffer)userdata1;
        const void* mapped = wgpuBufferGetConstMappedRange(buffer, 0, 32768 * 4 * sizeof(float));
        if (mapped) {
            memcpy(latest_chunk_data, mapped, 32768 * 4 * sizeof(float));
            chunk_data_ready = true;
        }
        wgpuBufferUnmap(buffer);
    }
}

static void gpu_readback_chunk_async(WGPUBuffer buffer) {
    if (is_mapping_chunk) return;
    is_mapping_chunk = true;
    chunk_data_ready = false;
    
    WGPUBufferMapCallbackInfo cb_info = {
        .nextInChain = NULL,
        .mode = WGPUCallbackMode_AllowProcessEvents,
        .callback = chunk_map_callback,
        .userdata1 = (void*)buffer,
        .userdata2 = NULL
    };
    
    wgpuBufferMapAsync(buffer, WGPUMapMode_Read, 0, 32768 * 4 * sizeof(float), cb_info);
}

static bool gpu_readback_is_chunk_mapping() {
    return is_mapping_chunk;
}

static bool gpu_readback_is_chunk_ready() {
    return chunk_data_ready;
}

static void gpu_readback_consume_chunk(float* out_data) {
    memcpy(out_data, latest_chunk_data, 32768 * 4 * sizeof(float));
    chunk_data_ready = false;
}

static WGPUBuffer gpu_readback_create_chunk_map_buffer(WGPUContext* ctx) {
    WGPUBufferDescriptor desc = {
        .nextInChain = NULL,
        .label = "ChunkMapBuffer",
        .usage = WGPUBufferUsage_MapRead | WGPUBufferUsage_CopyDst,
        .size = 32768 * 4 * sizeof(float),
        .mappedAtCreation = false
    };
    return wgpuDeviceCreateBuffer(ctx->device, &desc);
}
