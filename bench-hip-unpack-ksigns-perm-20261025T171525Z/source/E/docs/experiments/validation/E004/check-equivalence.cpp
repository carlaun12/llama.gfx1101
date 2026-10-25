
#include "ggml.h"
#define GGML_COMMON_DECL_C
#define GGML_COMMON_IMPL_C
#include "ggml-common.h"
#include <cmath>
#include <cstdio>
#include <cstring>
#include <random>
#include <climits>
struct int2 { int x, y; };
static int2 make_int2(int x,int y) { return {x,y}; }
static unsigned __popc(unsigned x) { return __builtin_popcount(x); }
static float __half2float(ggml_half x) { return ggml_fp16_to_fp32(x); }
static float __low2float(ggml_half2 x) { return ggml_fp16_to_fp32(x & 65535); }
static unsigned __vcmpne4(unsigned a,unsigned b) {
    unsigned result=0;
    for(int i=0;i<4;++i) if(((a>>(8*i))&255)!=((b>>(8*i))&255)) result|=255u<<(8*i);
    return result;
}
static unsigned __vsub4(unsigned a,unsigned b) {
    unsigned result=0;
    for(int i=0;i<4;++i) result|=(((a>>(8*i))-(b>>(8*i)))&255u)<<(8*i);
    return result;
}
static int ggml_cuda_dp4a(unsigned a,unsigned b,int sum) {
    for(int i=0;i<4;++i) sum+=int(int8_t(a>>(8*i)))*int(int8_t(b>>(8*i)));
    return sum;
}
static  inline int get_int_b2(const void * x, const int & i32) {
    const uint16_t * x16 = (const uint16_t *) x; // assume at least 2 byte alignment

    int x32  = x16[2*i32 + 0] <<  0;
    x32     |= x16[2*i32 + 1] << 16;

    return x32;
}
static  inline int get_int_b4(const void * x, const int & i32) {
    return ((const int *) x)[i32]; // assume at least 4 byte alignment
}
static  inline uint32_t unpack_ksigns(const uint8_t v) {
    // v is a 7 bit int, with the 8th sign being encodable as popcnt
    // with xor we can "correct" the bit instead of having to mask
    const uint32_t p = __popc(v) & 1;
    const uint32_t s = v ^ p << 7;
    // broadcast over uint to allow for 0x08040201 / 0x80402010 as selectors
    return s * 0x01010101;
}static  inline float dot_before(
    const void * __restrict__ vbq, const block_q8_1 * __restrict__ bq8_1, const int & kbx, const int & iqs) {

    const block_iq3_xxs * bq3 = (const block_iq3_xxs *) vbq + kbx;

    const int2 q3_packed = make_int2(get_int_b2(bq3->qs, iqs), get_int_b2(bq3->qs, iqs+1));
    const uint8_t * q3 = (const uint8_t *) &q3_packed;
    const uint32_t aux32 = get_int_b2(bq3->qs, QK_K/16 + iqs/2);

    int sumi = 0;
#pragma unroll
    for (int l0 = 0; l0 < 8; l0 += 2) {
        const int2 grid_pos = make_int2(iq3xxs_grid[q3[l0 + 0]], iq3xxs_grid[q3[l0 + 1]]);
        const uint32_t signs = unpack_ksigns(aux32 >> (7*l0/2));

        const int signs0 = __vcmpne4(signs & 0x08040201, 0);
        const int grid_l = __vsub4(grid_pos.x ^ signs0, signs0);

        const int u0 = get_int_b4(bq8_1[iqs/2].qs, l0 + 0);

        const int signs1 = __vcmpne4(signs & 0x80402010, 0);
        const int grid_h = __vsub4(grid_pos.y ^ signs1, signs1);

        const int u1 = get_int_b4(bq8_1[iqs/2].qs, l0 + 1);

        sumi = ggml_cuda_dp4a(grid_l, u0, sumi);
        sumi = ggml_cuda_dp4a(grid_h, u1, sumi);
    }

    const int ls = aux32 >> 28;
    sumi = (ls*sumi + sumi/2)/2;
    const float d = __half2float(bq3->d) * __low2float(bq8_1[iqs/2].ds);
    return d * sumi;
}
static  inline float dot_after(
    const void * __restrict__ vbq, const block_q8_1 * __restrict__ bq8_1, const int & kbx, const int & iqs) {

    const block_iq3_xxs * bq3 = (const block_iq3_xxs *) vbq + kbx;

    const int2 q3_packed = make_int2(get_int_b2(bq3->qs, iqs), get_int_b2(bq3->qs, iqs+1));
    const uint8_t * q3 = (const uint8_t *) &q3_packed;
    const uint32_t aux32 = get_int_b2(bq3->qs, QK_K/16 + iqs/2);

    int sumi0 = 0;
    int sumi1 = 0;
#pragma unroll
    for (int l0 = 0; l0 < 8; l0 += 2) {
        const int2 grid_pos = make_int2(iq3xxs_grid[q3[l0 + 0]], iq3xxs_grid[q3[l0 + 1]]);
        const uint32_t signs = unpack_ksigns(aux32 >> (7*l0/2));

        const int signs0 = __vcmpne4(signs & 0x08040201, 0);
        const int grid_l = __vsub4(grid_pos.x ^ signs0, signs0);

        const int u0 = get_int_b4(bq8_1[iqs/2].qs, l0 + 0);

        const int signs1 = __vcmpne4(signs & 0x80402010, 0);
        const int grid_h = __vsub4(grid_pos.y ^ signs1, signs1);

        const int u1 = get_int_b4(bq8_1[iqs/2].qs, l0 + 1);

        sumi0 = ggml_cuda_dp4a(grid_l, u0, sumi0);
        sumi1 = ggml_cuda_dp4a(grid_h, u1, sumi1);
    }

    int sumi = sumi0 + sumi1;
    const int ls = aux32 >> 28;
    sumi = (ls*sumi + sumi/2)/2;
    const float d = __half2float(bq3->d) * __low2float(bq8_1[iqs/2].ds);
    return d * sumi;
}
int main() {
    std::mt19937 random(12345);
    block_iq3_xxs weights[2]{};
    block_q8_1 input[8]{};
    size_t checks=0;
    for(int round=0;round<200000;++round) {
        const int block=round%2;
        weights[block].d=ggml_fp32_to_fp16(float(int(random()%2001)-1000)/1000.0f);
        for(auto & byte: weights[block].qs) byte=random();
        for(auto & part: input) {
            part.d=ggml_fp32_to_fp16(float(random()%1000)/1000.0f);
            for(auto & value:part.qs) value=int8_t(random());
        }
        if(round<256) {
            std::memset(weights[block].qs,round,sizeof(weights[block].qs));
            for(auto & part:input) for(auto & value:part.qs) value=(round&1)?127:-128;
        }
        for(int iqs=0;iqs<16;iqs+=2) {
            const float a=dot_before(weights,input,block,iqs);
            const float b=dot_after(weights,input,block,iqs);
            if(!std::isfinite(a)||!std::isfinite(b)||std::memcmp(&a,&b,sizeof(a))) return 1;
            ++checks;
        }
    }
    int max_grid=0;
    for(auto word:iq3xxs_grid) for(int i=0;i<4;++i) max_grid=std::max(max_grid,int((word>>(8*i))&255));
    const int64_t bound=int64_t(max_grid)*128*32;
    if(bound*15+bound/2>INT_MAX) return 2;
    std::printf("PASS: %zu bit-exact dot products; integer bound before final division: %lld\n",checks,(long long)(bound*15+bound/2));
}
