#include <hip/hip_runtime.h>
#include <cstdint>
#include <cstdio>

__global__ void check(uint32_t * out) {
    const uint32_t v = threadIdx.x;
    const uint32_t p = __popc(v) & 1u;
    const uint32_t s = v ^ (p << 7);
    const uint32_t old_value = s * 0x01010101u;
    const uint32_t candidate = __builtin_amdgcn_perm(0, s, 0);
    uint32_t parity = 0;
    for (uint32_t bit = 0; bit < 8; ++bit) {
        parity ^= (v >> bit) & 1u;
    }
    const uint8_t ref_byte = static_cast<uint8_t>(v ^ (parity << 7));
    const uint32_t reference = static_cast<uint32_t>(ref_byte) |
        (static_cast<uint32_t>(ref_byte) << 8) |
        (static_cast<uint32_t>(ref_byte) << 16) |
        (static_cast<uint32_t>(ref_byte) << 24);
    out[3 * v + 0] = old_value;
    out[3 * v + 1] = candidate;
    out[3 * v + 2] = reference;
}

int main() {
    uint32_t * device = nullptr;
    uint32_t host[256 * 3] = {};
    if (hipMalloc(&device, sizeof(host)) != hipSuccess) return 2;
    hipLaunchKernelGGL(check, dim3(1), dim3(256), 0, 0, device);
    if (hipDeviceSynchronize() != hipSuccess) return 3;
    if (hipMemcpy(host, device, sizeof(host), hipMemcpyDeviceToHost) != hipSuccess) return 4;
    unsigned mismatches = 0;
    for (uint32_t v = 0; v < 256; ++v) {
        if (host[3 * v] != host[3 * v + 1] || host[3 * v] != host[3 * v + 2]) {
            if (mismatches < 8) {
                std::printf("v=%u old=%08x candidate=%08x reference=%08x\n", v,
                    host[3 * v], host[3 * v + 1], host[3 * v + 2]);
            }
            ++mismatches;
        }
    }
    hipFree(device);
    std::printf("checked=256 mismatches=%u\n", mismatches);
    return mismatches == 0 ? 0 : 1;
}
