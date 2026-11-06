#pragma once
#include <webgpu/webgpu.h>
#include <string.h>
#include <stdbool.h>

#define RAYCAST_READBACK_FLOATS 144
#define RAYCAST_READBACK_BYTES (RAYCAST_READBACK_FLOATS * sizeof(float))

static float latest_hit_pos[RAYCAST_READBACK_FLOATS] = {0.0f};
static bool is_mapping = false;

static void buffer_map_callback(WGPUMapAsyncStatus status, WGPUStringView message, void* userdata1, void* userdata2) {
    is_mapping = false;
    if (status == WGPUMapAsyncStatus_Success) {
        WGPUBuffer buffer = (WGPUBuffer)userdata1;
        const void* mapped = wgpuBufferGetConstMappedRange(buffer, 0, RAYCAST_READBACK_BYTES);
        if (mapped) {
            memcpy(latest_hit_pos, mapped, RAYCAST_READBACK_BYTES);
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
    
    wgpuBufferMapAsync(buffer, WGPUMapMode_Read, 0, RAYCAST_READBACK_BYTES, cb_info);
}

static float* gpu_readback_get_raw() { return latest_hit_pos; }

static float gpu_readback_get_hit_x() { return latest_hit_pos[0]; }
static float gpu_readback_get_hit_y() { return latest_hit_pos[1]; }
static float gpu_readback_get_hit_z() { return latest_hit_pos[2]; }
static float gpu_readback_get_hit_w() { return latest_hit_pos[3]; }

static float gpu_readback_get_succ_x() { return latest_hit_pos[4]; }
static float gpu_readback_get_succ_y() { return latest_hit_pos[5]; }
static float gpu_readback_get_succ_z() { return latest_hit_pos[6]; }
static float gpu_readback_get_succ_w() { return latest_hit_pos[7]; }

static float gpu_readback_get_jet_x() { return latest_hit_pos[8]; }
static float gpu_readback_get_jet_y() { return latest_hit_pos[9]; }
static float gpu_readback_get_jet_z() { return latest_hit_pos[10]; }
static float gpu_readback_get_jet_w() { return latest_hit_pos[11]; }

static float gpu_readback_get_match_snuff() { return latest_hit_pos[12]; }
static float gpu_readback_get_hit_mat() { return latest_hit_pos[13]; }
static float gpu_readback_get_hit_stress() { return latest_hit_pos[14]; }
static float gpu_readback_get_hit_splash() { return latest_hit_pos[15]; }

static WGPUBuffer gpu_readback_create_map_buffer(WGPUContext* ctx) {
    WGPUBufferDescriptor desc = {
        .nextInChain = NULL,
        .label = "RaycastMapBuffer",
        .usage = WGPUBufferUsage_MapRead | WGPUBufferUsage_CopyDst,
        .size = RAYCAST_READBACK_BYTES,
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
