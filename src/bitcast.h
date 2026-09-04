#pragma once
#include <stdint.h>
#include <string.h>

static inline float int_to_float_bits(uint32_t i) {
    float f;
    memcpy(&f, &i, sizeof(float));
    return f;
}
