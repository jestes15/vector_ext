#include <arm_neon.h>

#include <cstring>

namespace simd
{
namespace neon
{
namespace __addition
{
void vec_add_u8x8(uint8_t dst[8], uint8_t src1[8], uint8_t src2[8])
{
    uint8x8_t v1 = vld1_u8(src1);
    uint8x8_t v2 = vld1_u8(src2);
    uint8x8_t v3 = vadd_u8(v1, v2);
    vst1_u8(dst, v3);
}

void vec_add_u8x16(uint8_t dst[16], uint8_t src1[16], uint8_t src2[16])
{
    uint8x16_t v1 = vld1q_u8(src1);
    uint8x16_t v2 = vld1q_u8(src2);
    uint8x16_t v3 = vaddq_u8(v1, v2);
    vst1q_u8(dst, v3);
}

void vec_add_u16x4(uint16_t dst[4], uint16_t src1[4], uint16_t src2[4])
{
    uint16x4_t v1 = vld1_u16(src1);
    uint16x4_t v2 = vld1_u16(src2);
    uint16x4_t v3 = vadd_u16(v1, v2);
    vst1_u16(dst, v3);
}

void vec_add_u16x8(uint16_t dst[8], uint16_t src1[8], uint16_t src2[8])
{
    uint16x8_t v1 = vld1q_u16(src1);
    uint16x8_t v2 = vld1q_u16(src2);
    uint16x8_t v3 = vaddq_u16(v1, v2);
    vst1q_u16(dst, v3);
}

void vec_add_u32x2(uint32_t dst[2], uint32_t src1[2], uint32_t src2[2])
{
    uint32x2_t v1 = vld1_u32(src1);
    uint32x2_t v2 = vld1_u32(src2);
    uint32x2_t v3 = vadd_u32(v1, v2);
    vst1_u32(dst, v3);
}

void vec_add_u32x4(uint32_t dst[4], uint32_t src1[4], uint32_t src2[4])
{
    uint32x4_t v1 = vld1q_u32(src1);
    uint32x4_t v2 = vld1q_u32(src2);
    uint32x4_t v3 = vaddq_u32(v1, v2);
    vst1q_u32(dst, v3);
}

void vec_add_u64x1(uint64_t dst[1], uint64_t src1[1], uint64_t src2[1])
{
    uint64x1_t v1 = vld1_u64(src1);
    uint64x1_t v2 = vld1_u64(src2);
    uint64x1_t v3 = vadd_u64(v1, v2);
    vst1_u64(dst, v3);
}

void vec_add_u64x2(uint64_t dst[2], uint64_t src1[2], uint64_t src2[2]) {
    uint64x2_t v1 = vld1q_u64(src1);
    uint64x2_t v2 = vld1q_u64(src2);
    uint64x2_t v3 = vaddq_u64(v1, v2);
    vst1q_u64(dst, v3);
}
} // namespace
namespace __subtraction {}
namespace __multiplication {}
namespace addition {}
namespace subtraction {}
namespace multiplication {}
} // namespace neon
} // namespace simd