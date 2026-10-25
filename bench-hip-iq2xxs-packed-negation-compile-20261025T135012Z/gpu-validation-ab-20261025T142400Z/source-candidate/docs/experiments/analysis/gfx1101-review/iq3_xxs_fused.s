
build-hip-baseline/bin/libggml-hip.so.36.hipv4-amdgcn-amd-amdhsa--gfx1101:	file format elf64-amdgpu

Disassembly of section .text:

0000000000153900 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj>:
	s_clause 0x2                                               // 000000153900: BF850002
	s_load_b128 s[24:27], s[0:1], 0x48                         // 000000153904: F4080600 F8000048
	s_load_b128 s[28:31], s[0:1], 0x20                         // 00000015390C: F4080700 F8000020
	s_load_b256 s[8:15], s[0:1], null                          // 000000153914: F40C0200 F8000000
	s_mov_b32 s20, s3                                          // 00000015391C: BE940003
	s_waitcnt lgkmcnt(0)                                       // 000000153920: BF89FC07
	s_cmp_lg_u64 s[24:25], 0                                   // 000000153924: BF118018
	s_cbranch_scc0 1012                                        // 000000153928: BFA103F4 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xffc>
	s_load_b32 s3, s[0:1], 0xc4                                // 00000015392C: F40000C0 F80000C4
	s_waitcnt lgkmcnt(0)                                       // 000000153934: BF89FC07
	s_add_i32 s3, s3, -1                                       // 000000153938: 8103C103
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000015393C: BF870009
	s_cmp_eq_u32 s20, s3                                       // 000000153940: BF060314
	s_cselect_b32 s5, -1, 0                                    // 000000153944: 980580C1
	s_clause 0x1                                               // 000000153948: BF850001
	s_load_b128 s[36:39], s[0:1], 0x70                         // 00000015394C: F4080900 F8000070
	s_load_b128 s[16:19], s[0:1], 0x98                         // 000000153954: F4080400 F8000098
	s_cbranch_execnz 1                                         // 00000015395C: BFA60001 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x64>
	s_mov_b32 s5, 0                                            // 000000153960: BE850080
	s_clause 0x1                                               // 000000153964: BF850001
	s_load_b32 s41, s[0:1], 0x80                               // 000000153968: F4000A40 F8000080
	s_load_b32 s40, s[0:1], 0xa8                               // 000000153970: F4000A00 F80000A8
	s_and_b32 vcc_lo, exec_lo, s5                              // 000000153978: 8B6A057E
	s_mov_b32 s42, 0                                           // 00000015397C: BEAA0080
	s_cbranch_vccnz 18                                         // 000000153980: BFA40012 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xcc>
	s_cmp_eq_u64 s[12:13], 0                                   // 000000153984: BF10800C
	s_mov_b32 s21, 0                                           // 000000153988: BE950080
	s_cbranch_scc1 993                                         // 00000015398C: BFA203E1 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1014>
	s_lshl_b64 s[6:7], s[20:21], 2                             // 000000153990: 84868214
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000153994: BF870009
	s_add_u32 s6, s12, s6                                      // 000000153998: 8006060C
	s_addc_u32 s7, s13, s7                                     // 00000015399C: 8207070D
	s_load_b32 s42, s[6:7], null                               // 0000001539A0: F4000A83 F8000000
	s_and_not1_b32 vcc_lo, exec_lo, s21                        // 0000001539A8: 916A157E
	s_cbranch_vccnz 7                                          // 0000001539AC: BFA40007 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xcc>
	s_load_b64 s[6:7], s[0:1], 0x8c                            // 0000001539B0: F4040180 F800008C
	s_waitcnt lgkmcnt(0)                                       // 0000001539B8: BF89FC07
	s_mul_hi_u32 s3, s20, s6                                   // 0000001539BC: 96830614
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 0000001539C0: BF870499
	s_add_i32 s3, s20, s3                                      // 0000001539C4: 81030314
	s_lshr_b32 s42, s3, s7                                     // 0000001539C8: 852A0703
	s_load_b64 s[6:7], s[0:1], 0x58                            // 0000001539CC: F4040180 F8000058
	s_and_b32 s3, exec_lo, s5                                  // 0000001539D4: 8B03057E
	s_cselect_b32 s33, 0, s20                                  // 0000001539D8: 98211480
	s_cmp_eq_u64 s[12:13], 0                                   // 0000001539DC: BF10800C
	s_mov_b32 s3, s33                                          // 0000001539E0: BE830021
	s_mov_b32 s43, s33                                         // 0000001539E4: BEAB0021
	s_cbranch_scc1 9                                           // 0000001539E8: BFA20009 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x110>
	s_waitcnt lgkmcnt(0)                                       // 0000001539EC: BF89FC07
	s_mul_hi_u32 s3, s33, s37                                  // 0000001539F0: 96832521
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 0000001539F4: BF870499
	s_add_i32 s3, s33, s3                                      // 0000001539F8: 81030321
	s_lshr_b32 s3, s3, s38                                     // 0000001539FC: 85032603
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000153A00: BF870499
	s_mul_i32 s3, s3, s39                                      // 000000153A04: 96032703
	s_sub_i32 s43, s33, s3                                     // 000000153A08: 81AB0321
	s_mov_b32 s3, s42                                          // 000000153A0C: BE83002A
	s_clause 0x1                                               // 000000153A10: BF850001
	s_load_b64 s[12:13], s[0:1], 0x40                          // 000000153A14: F4040300 F8000040
	s_load_b128 s[20:23], s[0:1], 0xb0                         // 000000153A1C: F4080500 F80000B0
	v_bfe_u32 v13, v0, 10, 10                                  // 000000153A24: D610000D 02291500
	v_dual_mov_b32 v11, 0 :: v_dual_and_b32 v10, 0x3ff, v0     // 000000153A2C: CA240080 0B0A00FF 000003FF
	v_mov_b32_e32 v12, 0                                       // 000000153A38: 7E180280
	s_cmp_lg_u64 s[28:29], 0                                   // 000000153A3C: BF11801C
	s_waitcnt lgkmcnt(0)                                       // 000000153A40: BF89FC07
	s_mov_b32 s37, exec_lo                                     // 000000153A44: BEA5007E
	v_or_b32_e32 v0, v10, v13                                  // 000000153A48: 38001B0A
	s_cselect_b32 s23, -1, 0                                   // 000000153A4C: 981780C1
	s_delay_alu instid0(VALU_DEP_1)                            // 000000153A50: BF870001
	v_cmpx_eq_u32_e32 0, v0                                    // 000000153A54: 7D940080
	s_cbranch_execz 46                                         // 000000153A58: BFA5002E <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x214>
	v_dual_mov_b32 v11, 0 :: v_dual_lshlrev_b32 v0, 2, v10     // 000000153A5C: CA220080 0B001482
	v_mov_b32_e32 v12, 0                                       // 000000153A64: 7E180280
	s_cmp_eq_u64 s[14:15], 0                                   // 000000153A68: BF10800E
	s_mul_i32 s34, s3, s18                                     // 000000153A6C: 96221203
	s_cbranch_scc1 17                                          // 000000153A70: BFA20011 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1b8>
	s_mul_i32 s38, s22, s4                                     // 000000153A74: 96260416
	s_mov_b32 s39, 0                                           // 000000153A78: BEA70080
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 000000153A7C: BF8704D9
	s_lshl_b64 s[44:45], s[38:39], 2                           // 000000153A80: 84AC8226
	s_mov_b32 s35, s39                                         // 000000153A84: BEA30027
	s_add_u32 s3, s14, s44                                     // 000000153A88: 80032C0E
	s_addc_u32 s38, s15, s45                                   // 000000153A8C: 82262D0F
	s_lshl_b64 s[14:15], s[34:35], 2                           // 000000153A90: 848E8222
	s_add_u32 s35, s3, s14                                     // 000000153A94: 80230E03
	s_addc_u32 s38, s38, s15                                   // 000000153A98: 82260F26
	s_ashr_i32 s3, s2, 31                                      // 000000153A9C: 86039F02
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000153AA0: BF870499
	s_lshl_b64 s[14:15], s[2:3], 2                             // 000000153AA4: 848E8202
	s_add_u32 s14, s35, s14                                    // 000000153AA8: 800E0E23
	s_addc_u32 s15, s38, s15                                   // 000000153AAC: 820F0F26
	global_load_b32 v12, v0, s[14:15]                          // 000000153AB0: DC520000 0C0E0000
	s_cmp_lg_u64 s[30:31], 0                                   // 000000153AB8: BF11801E
	s_cselect_b32 s3, -1, 0                                    // 000000153ABC: 980380C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000153AC0: BF870499
	s_and_b32 s3, s3, s23                                      // 000000153AC4: 8B031703
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 000000153AC8: 916A037E
	s_cbranch_vccnz 17                                         // 000000153ACC: BFA40011 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x214>
	s_mul_i32 s14, s22, s4                                     // 000000153AD0: 960E0416
	s_mov_b32 s15, 0                                           // 000000153AD4: BE8F0080
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 000000153AD8: BF8704D9
	s_lshl_b64 s[38:39], s[14:15], 2                           // 000000153ADC: 84A6820E
	s_mov_b32 s35, s15                                         // 000000153AE0: BEA3000F
	s_add_u32 s3, s30, s38                                     // 000000153AE4: 8003261E
	s_addc_u32 s30, s31, s39                                   // 000000153AE8: 821E271F
	s_lshl_b64 s[14:15], s[34:35], 2                           // 000000153AEC: 848E8222
	s_add_u32 s31, s3, s14                                     // 000000153AF0: 801F0E03
	s_addc_u32 s30, s30, s15                                   // 000000153AF4: 821E0F1E
	s_ashr_i32 s3, s2, 31                                      // 000000153AF8: 86039F02
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000153AFC: BF870499
	s_lshl_b64 s[14:15], s[2:3], 2                             // 000000153B00: 848E8202
	s_add_u32 s14, s31, s14                                    // 000000153B04: 800E0E1F
	s_addc_u32 s15, s30, s15                                   // 000000153B08: 820F0F1E
	global_load_b32 v11, v0, s[14:15]                          // 000000153B0C: DC520000 0B0E0000
	s_or_b32 exec_lo, exec_lo, s37                             // 000000153B14: 8C7E257E
	v_lshl_add_u32 v0, v13, 5, v10                             // 000000153B18: D6460000 04290B0D
	v_dual_mov_b32 v16, 0 :: v_dual_mov_b32 v15, 0             // 000000153B20: CA100080 100E0080
	v_cndmask_b32_e64 v14, 0, 1, s23                           // 000000153B28: D501000E 005D0280
	s_lshr_b32 s30, s36, 8                                     // 000000153B30: 851E8824
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000153B34: BF8700A3
	v_lshrrev_b32_e32 v17, 3, v0                               // 000000153B38: 32220083
	s_mov_b32 s31, exec_lo                                     // 000000153B3C: BE9F007E
	v_cmpx_gt_u32_e64 s30, v17                                 // 000000153B40: D4CC007E 0002221E
	s_cbranch_execz 721                                        // 000000153B48: BFA502D1 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xd90>
	v_lshrrev_b32_e32 v2, 3, v0                                // 000000153B4C: 32040083
	s_mul_i32 s3, s43, s17                                     // 000000153B50: 9603112B
	v_dual_mov_b32 v16, 0 :: v_dual_and_b32 v5, 7, v10         // 000000153B54: CA240080 10041487
	s_mul_hi_u32 s15, s3, 36                                   // 000000153B5C: 968FA403
	s_mul_i32 s14, s3, 36                                      // 000000153B60: 960EA403
	v_dual_mov_b32 v15, 0 :: v_dual_lshlrev_b32 v4, 1, v10     // 000000153B64: CA220080 0F041481
	v_mad_u64_u32 v[0:1], null, 0x120, v2, s[14:15]            // 000000153B6C: D6FE7C00 003A04FF 00000120
	s_mul_i32 s14, s21, s4                                     // 000000153B78: 960E0415
	v_and_b32_e32 v4, 14, v4                                   // 000000153B7C: 3608088E
	s_mul_hi_u32 s3, s19, s4                                   // 000000153B80: 96830413
	s_mul_i32 s41, s41, s2                                     // 000000153B84: 96290229
	s_add_i32 s3, s4, s3                                       // 000000153B88: 81030304
	s_mul_i32 s17, s42, s16                                    // 000000153B8C: 9611102A
	v_mad_u64_u32 v[2:3], null, s14, 36, v[0:1]                // 000000153B90: D6FE7C02 0401480E
	s_lshr_b32 s3, s3, s40                                     // 000000153B98: 85032803
	s_and_b32 s14, exec_lo, s5                                 // 000000153B9C: 8B0E057E
	s_mul_i32 s3, s3, s20                                      // 000000153BA0: 96031403
	v_lshlrev_b32_e32 v19, 1, v4                               // 000000153BA4: 30260881
	s_cselect_b32 s15, s27, s29                                // 000000153BA8: 980F1D1B
	s_cselect_b32 s14, s26, s28                                // 000000153BAC: 980E1C1A
	v_mad_u64_u32 v[0:1], null, v5, 36, v[2:3]                 // 000000153BB0: D6FE7C00 04094905
	v_lshlrev_b32_e32 v2, 1, v4                                // 000000153BB8: 30040881
	s_cselect_b32 s9, s25, s9                                  // 000000153BBC: 98090919
	s_cselect_b32 s8, s24, s8                                  // 000000153BC0: 98080818
	s_add_i32 s3, s3, s41                                      // 000000153BC4: 81032903
	s_mov_b32 s16, 0                                           // 000000153BC8: BE900080
	v_lshlrev_b32_e32 v18, 1, v2                               // 000000153BCC: 30240481
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000153BD0: BF870093
	v_add_co_u32 v0, vcc_lo, s10, v0                           // 000000153BD4: D7006A00 0002000A
	v_add_co_ci_u32_e64 v1, null, s11, v1, vcc_lo              // 000000153BDC: D5207C01 01AA020B
	s_add_i32 s17, s17, s3                                     // 000000153BE4: 81110311
	v_add_co_u32 v8, vcc_lo, v0, 32                            // 000000153BE8: D7006A08 00014100
	s_delay_alu instid0(VALU_DEP_1)                            // 000000153BF0: BF870001
	v_add_co_ci_u32_e64 v9, null, 0, v1, vcc_lo                // 000000153BF4: D5207C09 01AA0280
	s_getpc_b64 s[10:11]                                       // 000000153BFC: BE8A4700
	s_add_u32 s10, s10, 0xfff4cf00                             // 000000153C00: 800AFF0A FFF4CF00
	s_addc_u32 s11, s11, -1                                    // 000000153C08: 820BFF0B FFFFFFFF
	s_branch 264                                               // 000000153C10: BFA00108 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x734>
	v_and_b32_e32 v31, 0xff, v20                               // 000000153C14: 363E28FF 000000FF
	v_bfe_u32 v32, v20, 7, 8                                   // 000000153C1C: D6100020 02210F14
	v_bfe_u32 v33, v20, 14, 8                                  // 000000153C24: D6100021 02211D14
	v_bfe_u32 v35, v20, 21, 8                                  // 000000153C2C: D6100023 02212B14
	v_add_nc_u32_e32 v17, 4, v17                               // 000000153C34: 4A222284
	v_bcnt_u32_b32 v34, v31, 0                                 // 000000153C38: D71E0022 0001011F
	v_bcnt_u32_b32 v36, v32, 0                                 // 000000153C40: D71E0024 00010120
	v_bcnt_u32_b32 v37, v33, 0                                 // 000000153C48: D71E0025 00010121
	v_bcnt_u32_b32 v38, v35, 0                                 // 000000153C50: D71E0026 00010123
	v_cmp_le_u32_e32 vcc_lo, s30, v17                          // 000000153C58: 7C96221E
	v_and_b32_e32 v34, 1, v34                                  // 000000153C5C: 36444481
	v_and_b32_e32 v36, 1, v36                                  // 000000153C60: 36484881
	v_and_b32_e32 v37, 1, v37                                  // 000000153C64: 364A4A81
	v_and_b32_e32 v38, 1, v38                                  // 000000153C68: 364C4C81
	v_add_co_u32 v8, s3, 0x480, v8                             // 000000153C6C: D7000308 000210FF 00000480
	v_lshlrev_b32_e32 v34, 7, v34                              // 000000153C78: 30444487
	v_lshlrev_b32_e32 v36, 7, v36                              // 000000153C7C: 30484887
	v_lshlrev_b32_e32 v37, 7, v37                              // 000000153C80: 304A4A87
	v_add_co_ci_u32_e64 v9, null, 0, v9, s3                    // 000000153C84: D5207C09 000E1280
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 000000153C8C: BF870214
	v_xor_b32_e32 v31, v34, v31                                // 000000153C90: 3A3E3F22
	v_xor_b32_e32 v32, v36, v32                                // 000000153C94: 3A404124
	s_delay_alu instid0(VALU_DEP_4)                            // 000000153C98: BF870004
	v_xor_b32_e32 v33, v37, v33                                // 000000153C9C: 3A424325
	v_lshlrev_b32_e32 v34, 7, v38                              // 000000153CA0: 30444C87
	s_waitcnt vmcnt(7)                                         // 000000153CA4: BF891FF7
	v_and_b32_e32 v36, 0x80808080, v30                         // 000000153CA8: 36483CFF 80808080
	v_mul_lo_u32 v31, 0x1010101, v31                           // 000000153CB0: D72C001F 00023EFF 01010101
	v_mul_lo_u32 v32, 0x1010101, v32                           // 000000153CBC: D72C0020 000240FF 01010101
	v_mul_lo_u32 v33, 0x1010101, v33                           // 000000153CC8: D72C0021 000242FF 01010101
	v_xor_b32_e32 v34, v34, v35                                // 000000153CD4: 3A444722
	s_waitcnt vmcnt(6)                                         // 000000153CD8: BF891BF7
	v_and_b32_e32 v35, 0x80808080, v29                         // 000000153CDC: 36463AFF 80808080
	s_waitcnt vmcnt(5)                                         // 000000153CE4: BF8917F7
	v_and_b32_e32 v37, 0x80808080, v28                         // 000000153CE8: 364A38FF 80808080
	s_waitcnt vmcnt(4)                                         // 000000153CF0: BF8913F7
	v_and_b32_e32 v38, 0x80808080, v27                         // 000000153CF4: 364C36FF 80808080
	s_or_b32 s16, vcc_lo, s16                                  // 000000153CFC: 8C10106A
	v_and_b32_e32 v39, 0x8040201, v31                          // 000000153D00: 364E3EFF 08040201
	v_and_b32_e32 v31, 0x80402010, v31                         // 000000153D08: 363E3EFF 80402010
	v_and_b32_e32 v40, 0x8040201, v32                          // 000000153D10: 365040FF 08040201
	v_and_b32_e32 v32, 0x80402010, v32                         // 000000153D18: 364040FF 80402010
	v_and_b32_e32 v41, 0x8040201, v33                          // 000000153D20: 365242FF 08040201
	v_add_nc_u32_e32 v39, 0x7f7f7f7f, v39                      // 000000153D28: 4A4E4EFF 7F7F7F7F
	v_add_nc_u32_e32 v31, 0x7f7f7f7f, v31                      // 000000153D30: 4A3E3EFF 7F7F7F7F
	v_add_nc_u32_e32 v40, 0x7f7f7f7f, v40                      // 000000153D38: 4A5050FF 7F7F7F7F
	v_add_nc_u32_e32 v32, 0x7f7f7f7f, v32                      // 000000153D40: 4A4040FF 7F7F7F7F
	v_mul_lo_u32 v34, 0x1010101, v34                           // 000000153D48: D72C0022 000244FF 01010101
	v_lshrrev_b32_e32 v39, 7, v39                              // 000000153D54: 324E4E87
	v_lshrrev_b32_e32 v31, 7, v31                              // 000000153D58: 323E3E87
	v_lshrrev_b32_e32 v40, 7, v40                              // 000000153D5C: 32505087
	v_lshrrev_b32_e32 v32, 7, v32                              // 000000153D60: 32404087
	v_and_b32_e32 v33, 0x80402010, v33                         // 000000153D64: 364242FF 80402010
	v_and_b32_e32 v39, 0x1010101, v39                          // 000000153D6C: 364E4EFF 01010101
	v_and_b32_e32 v31, 0x1010101, v31                          // 000000153D74: 363E3EFF 01010101
	v_and_b32_e32 v40, 0x1010101, v40                          // 000000153D7C: 365050FF 01010101
	v_add_nc_u32_e32 v41, 0x7f7f7f7f, v41                      // 000000153D84: 4A5252FF 7F7F7F7F
	v_and_b32_e32 v32, 0x1010101, v32                          // 000000153D8C: 364040FF 01010101
	v_mul_lo_u32 v39, 0xff, v39                                // 000000153D94: D72C0027 00024EFF 000000FF
	v_mul_lo_u32 v31, 0xff, v31                                // 000000153DA0: D72C001F 00023EFF 000000FF
	v_mul_lo_u32 v40, 0xff, v40                                // 000000153DAC: D72C0028 000250FF 000000FF
	v_and_b32_e32 v42, 0x8040201, v34                          // 000000153DB8: 365444FF 08040201
	v_add_nc_u32_e32 v33, 0x7f7f7f7f, v33                      // 000000153DC0: 4A4242FF 7F7F7F7F
	v_lshrrev_b32_e32 v41, 7, v41                              // 000000153DC8: 32525287
	v_mul_lo_u32 v32, 0xff, v32                                // 000000153DCC: D72C0020 000240FF 000000FF
	v_and_b32_e32 v34, 0x80402010, v34                         // 000000153DD8: 364444FF 80402010
	v_xor_b32_e32 v30, v39, v30                                // 000000153DE0: 3A3C3D27
	v_and_b32_e32 v39, 0x7f7f7f7f, v39                         // 000000153DE4: 364E4EFF 7F7F7F7F
	v_xor_b32_e32 v29, v31, v29                                // 000000153DEC: 3A3A3B1F
	v_and_b32_e32 v31, 0x7f7f7f7f, v31                         // 000000153DF0: 363E3EFF 7F7F7F7F
	v_xor_b32_e32 v28, v40, v28                                // 000000153DF8: 3A383928
	v_or_b32_e32 v30, 0x80808080, v30                          // 000000153DFC: 383C3CFF 80808080
	v_add_nc_u32_e32 v42, 0x7f7f7f7f, v42                      // 000000153E04: 4A5454FF 7F7F7F7F
	v_or_b32_e32 v29, 0x80808080, v29                          // 000000153E0C: 383A3AFF 80808080
	v_lshrrev_b32_e32 v33, 7, v33                              // 000000153E14: 32424287
	v_and_b32_e32 v41, 0x1010101, v41                          // 000000153E18: 365252FF 01010101
	v_sub_nc_u32_e32 v30, v30, v39                             // 000000153E20: 4C3C4F1E
	v_and_b32_e32 v40, 0x7f7f7f7f, v40                         // 000000153E24: 365050FF 7F7F7F7F
	v_sub_nc_u32_e32 v29, v29, v31                             // 000000153E2C: 4C3A3F1D
	v_xor_b32_e32 v27, v32, v27                                // 000000153E30: 3A363720
	v_or_b32_e32 v28, 0x80808080, v28                          // 000000153E34: 383838FF 80808080
	v_xor3_b32 v30, v36, v30, 0x80808080                       // 000000153E3C: D640001E 03FE3D24 80808080
	v_add_nc_u32_e32 v34, 0x7f7f7f7f, v34                      // 000000153E48: 4A4444FF 7F7F7F7F
	v_lshrrev_b32_e32 v42, 7, v42                              // 000000153E50: 32545487
	v_and_b32_e32 v33, 0x1010101, v33                          // 000000153E54: 364242FF 01010101
	v_mul_lo_u32 v41, 0xff, v41                                // 000000153E5C: D72C0029 000252FF 000000FF
	v_xor3_b32 v29, v35, v29, 0x80808080                       // 000000153E68: D640001D 03FE3B23 80808080
	v_dot4_i32_iu8 v5, v30, v5, 0 neg_lo:[1,1,0]               // 000000153E74: CC164005 7A020B1E
	v_and_b32_e32 v32, 0x7f7f7f7f, v32                         // 000000153E7C: 364040FF 7F7F7F7F
	v_or_b32_e32 v27, 0x80808080, v27                          // 000000153E84: 383636FF 80808080
	v_sub_nc_u32_e32 v28, v28, v40                             // 000000153E8C: 4C38511C
	v_mul_lo_u32 v31, 0xff, v33                                // 000000153E90: D72C001F 000242FF 000000FF
	v_lshrrev_b32_e32 v30, 7, v34                              // 000000153E9C: 323C4487
	v_dot4_i32_iu8 v5, v29, v6, v5 neg_lo:[1,1,0]              // 000000153EA0: CC164005 7C160D1D
	v_and_b32_e32 v6, 0x1010101, v42                           // 000000153EA8: 360C54FF 01010101
	v_sub_nc_u32_e32 v27, v27, v32                             // 000000153EB0: 4C36411B
	s_waitcnt vmcnt(3)                                         // 000000153EB4: BF890FF7
	v_xor_b32_e32 v32, v41, v26                                // 000000153EB8: 3A403529
	v_xor3_b32 v28, v37, v28, 0x80808080                       // 000000153EBC: D640001C 03FE3925 80808080
	v_and_b32_e32 v30, 0x1010101, v30                          // 000000153EC8: 363C3CFF 01010101
	v_mul_lo_u32 v6, 0xff, v6                                  // 000000153ED0: D72C0006 00020CFF 000000FF
	v_xor3_b32 v27, v38, v27, 0x80808080                       // 000000153EDC: D640001B 03FE3726 80808080
	v_or_b32_e32 v29, 0x80808080, v32                          // 000000153EE8: 383A40FF 80808080
	s_waitcnt vmcnt(2)                                         // 000000153EF0: BF890BF7
	v_xor_b32_e32 v32, v31, v25                                // 000000153EF4: 3A40331F
	v_and_b32_e32 v33, 0x7f7f7f7f, v41                         // 000000153EF8: 364252FF 7F7F7F7F
	v_dot4_i32_iu8 v5, v28, v7, v5 neg_lo:[1,1,0]              // 000000153F00: CC164005 7C160F1C
	v_mul_lo_u32 v30, 0xff, v30                                // 000000153F08: D72C001E 00023CFF 000000FF
	v_and_b32_e32 v28, 0x7f7f7f7f, v31                         // 000000153F14: 36383EFF 7F7F7F7F
	v_or_b32_e32 v7, 0x80808080, v32                           // 000000153F1C: 380E40FF 80808080
	v_sub_nc_u32_e32 v29, v29, v33                             // 000000153F24: 4C3A431D
	v_and_b32_e32 v26, 0x80808080, v26                         // 000000153F28: 363434FF 80808080
	v_dot4_i32_iu8 v0, v27, v0, v5 neg_lo:[1,1,0]              // 000000153F30: CC164000 7C16011B
	s_waitcnt vmcnt(1)                                         // 000000153F38: BF8907F7
	v_xor_b32_e32 v5, v24, v6                                  // 000000153F3C: 3A0A0D18
	v_sub_nc_u32_e32 v7, v7, v28                               // 000000153F40: 4C0E3907
	v_and_b32_e32 v25, 0x80808080, v25                         // 000000153F44: 363232FF 80808080
	v_xor3_b32 v26, v26, v29, 0x80808080                       // 000000153F4C: D640001A 03FE3B1A 80808080
	s_waitcnt vmcnt(0)                                         // 000000153F58: BF8903F7
	v_xor_b32_e32 v27, v23, v30                                // 000000153F5C: 3A363D17
	v_or_b32_e32 v5, 0x80808080, v5                            // 000000153F60: 380A0AFF 80808080
	v_and_b32_e32 v6, 0x7f7f7f7f, v6                           // 000000153F68: 360C0CFF 7F7F7F7F
	v_xor3_b32 v7, v25, v7, 0x80808080                         // 000000153F70: D6400007 03FE0F19 80808080
	v_dot4_i32_iu8 v0, v26, v1, v0 neg_lo:[1,1,0]              // 000000153F7C: CC164000 7C02031A
	v_or_b32_e32 v1, 0x80808080, v27                           // 000000153F84: 380236FF 80808080
	v_and_b32_e32 v25, 0x7f7f7f7f, v30                         // 000000153F8C: 36323CFF 7F7F7F7F
	v_sub_nc_u32_e32 v5, v5, v6                                // 000000153F94: 4C0A0D05
	v_and_b32_e32 v6, 0x80808080, v24                          // 000000153F98: 360C30FF 80808080
	v_dot4_i32_iu8 v0, v7, v2, v0 neg_lo:[1,1,0]               // 000000153FA0: CC164000 7C020507
	v_and_b32_e32 v2, 0x80808080, v23                          // 000000153FA8: 36042EFF 80808080
	v_sub_nc_u32_e32 v1, v1, v25                               // 000000153FB0: 4C023301
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000153FB4: BF870114
	v_xor3_b32 v5, v6, v5, 0x80808080                          // 000000153FB8: D6400005 03FE0B06 80808080
	v_xor3_b32 v1, v2, v1, 0x80808080                          // 000000153FC4: D6400001 03FE0302 80808080
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000153FD0: BF870122
	v_dot4_i32_iu8 v0, v5, v3, v0 neg_lo:[1,1,0]               // 000000153FD4: CC164000 7C020705
	v_lshrrev_b32_e32 v5, 28, v20                              // 000000153FDC: 320A289C
	v_dot4_i32_iu8 v3, v1, v21, v0 neg_lo:[1,1,0]              // 000000153FE0: CC164003 7C022B01
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000153FE8: BF870091
	v_lshrrev_b32_e32 v0, 31, v3                               // 000000153FEC: 3200069F
	v_add_nc_u32_e32 v0, v3, v0                                // 000000153FF0: 4A000103
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000153FF4: BF870091
	v_ashrrev_i32_e32 v0, 1, v0                                // 000000153FF8: 34000081
	v_mad_u64_u32 v[1:2], null, v3, v5, v[0:1]                 // 000000153FFC: D6FE7C01 04020B03
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154004: BF870091
	v_lshrrev_b32_e32 v0, 31, v1                               // 000000154008: 3200029F
	v_add_nc_u32_e32 v0, v1, v0                                // 00000015400C: 4A000101
	v_cvt_f32_f16_e32 v1, v4.h                                 // 000000154010: 7E021784
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000154014: BF870112
	v_ashrrev_i32_e32 v0, 1, v0                                // 000000154018: 34000081
	v_mul_f32_e32 v1, v1, v22                                  // 00000015401C: 10022D01
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154020: BF870092
	v_cvt_f32_i32_e32 v0, v0                                   // 000000154024: 7E000B00
	v_fmac_f32_e32 v16, v1, v0                                 // 000000154028: 56200101
	s_and_not1_b32 exec_lo, exec_lo, s16                       // 00000015402C: 917E107E
	s_cbranch_execz 406                                        // 000000154030: BFA50196 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xd8c>
	v_add_nc_u32_e32 v31, s17, v17                             // 000000154034: 4A3E2211
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154038: BF870091
	v_mad_i64_i32 v[22:23], null, 0x62, v31, s[8:9]            // 00000015403C: D6FF7C16 00223EFF 00000062
	v_add_co_u32 v0, vcc_lo, v22, v18                          // 000000154048: D7006A00 00022516
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000154050: BF8700A1
	v_add_co_ci_u32_e64 v1, null, 0, v23, vcc_lo               // 000000154054: D5207C01 01AA2E80
	v_add_co_u32 v26, vcc_lo, v22, v19                         // 00000015405C: D7006A1A 00022716
	v_add_co_ci_u32_e64 v27, null, 0, v23, vcc_lo              // 000000154064: D5207C1B 01AA2E80
	global_load_b64 v[24:25], v[0:1], off offset:2             // 00000015406C: DC560002 187C0000
	s_clause 0x2                                               // 000000154074: BF850002
	global_load_b128 v[4:7], v[8:9], off offset:-32            // 000000154078: DC5E1FE0 047C0008
	global_load_b128 v[0:3], v[8:9], off offset:-16            // 000000154080: DC5E1FF0 007C0008
	global_load_b32 v21, v[8:9], off                           // 000000154088: DC520000 157C0008
	s_clause 0x1                                               // 000000154090: BF850001
	global_load_b32 v20, v[26:27], off offset:66               // 000000154094: DC520042 147C001A
	global_load_d16_hi_b16 v4, v[22:23], off                   // 00000015409C: DC8E0000 047C0016
	s_and_not1_b32 vcc_lo, exec_lo, s23                        // 0000001540A4: 916A177E
	s_waitcnt vmcnt(5)                                         // 0000001540A8: BF8917F7
	v_and_b32_e32 v22, 0xff, v24                               // 0000001540AC: 362C30FF 000000FF
	v_lshrrev_b32_e32 v23, 6, v24                              // 0000001540B4: 322E3086
	v_lshrrev_b32_e32 v26, 14, v24                             // 0000001540B8: 3234308E
	v_lshrrev_b32_e32 v24, 22, v24                             // 0000001540BC: 32303096
	v_and_b32_e32 v27, 0xff, v25                               // 0000001540C0: 363632FF 000000FF
	v_lshrrev_b32_e32 v28, 6, v25                              // 0000001540C8: 32383286
	v_lshrrev_b32_e32 v29, 14, v25                             // 0000001540CC: 323A328E
	v_lshrrev_b32_e32 v25, 22, v25                             // 0000001540D0: 32323296
	v_lshlrev_b32_e32 v22, 2, v22                              // 0000001540D4: 302C2C82
	v_and_b32_e32 v23, 0x3fc, v23                              // 0000001540D8: 362E2EFF 000003FC
	v_and_b32_e32 v26, 0x3fc, v26                              // 0000001540E0: 363434FF 000003FC
	v_and_b32_e32 v24, 0x3fc, v24                              // 0000001540E8: 363030FF 000003FC
	v_lshlrev_b32_e32 v32, 2, v27                              // 0000001540F0: 30403682
	v_and_b32_e32 v33, 0x3fc, v28                              // 0000001540F4: 364238FF 000003FC
	v_and_b32_e32 v34, 0x3fc, v29                              // 0000001540FC: 36443AFF 000003FC
	v_and_b32_e32 v35, 0x3fc, v25                              // 000000154104: 364632FF 000003FC
	s_clause 0x7                                               // 00000015410C: BF850007
	global_load_b32 v30, v22, s[10:11]                         // 000000154110: DC520000 1E0A0016
	global_load_b32 v29, v23, s[10:11]                         // 000000154118: DC520000 1D0A0017
	global_load_b32 v28, v26, s[10:11]                         // 000000154120: DC520000 1C0A001A
	global_load_b32 v27, v24, s[10:11]                         // 000000154128: DC520000 1B0A0018
	global_load_b32 v26, v32, s[10:11]                         // 000000154130: DC520000 1A0A0020
	global_load_b32 v25, v33, s[10:11]                         // 000000154138: DC520000 190A0021
	global_load_b32 v24, v34, s[10:11]                         // 000000154140: DC520000 180A0022
	global_load_b32 v23, v35, s[10:11]                         // 000000154148: DC520000 170A0023
	s_waitcnt vmcnt(8)                                         // 000000154150: BF8923F7
	v_cvt_f32_f16_e32 v22, v4.l                                // 000000154154: 7E2C1704
	s_cbranch_vccnz 65198                                      // 000000154158: BFA4FEAE <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x314>
	v_mad_i64_i32 v[32:33], null, 0x62, v31, s[14:15]          // 00000015415C: D6FF7C20 003A3EFF 00000062
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154168: BF870091
	v_add_co_u32 v34, vcc_lo, v32, v18                         // 00000015416C: D7006A22 00022520
	v_add_co_ci_u32_e64 v35, null, 0, v33, vcc_lo              // 000000154174: D5207C23 01AA4280
	v_add_co_u32 v36, vcc_lo, v32, v19                         // 00000015417C: D7006A24 00022720
	s_delay_alu instid0(VALU_DEP_1)                            // 000000154184: BF870001
	v_add_co_ci_u32_e64 v37, null, 0, v33, vcc_lo              // 000000154188: D5207C25 01AA4280
	s_clause 0x1                                               // 000000154190: BF850001
	global_load_b64 v[34:35], v[34:35], off offset:2           // 000000154194: DC560002 227C0022
	global_load_b32 v31, v[36:37], off offset:66               // 00000015419C: DC520042 1F7C0024
	s_waitcnt vmcnt(1)                                         // 0000001541A4: BF8907F7
	v_and_b32_e32 v36, 0xff, v34                               // 0000001541A8: 364844FF 000000FF
	v_lshrrev_b32_e32 v37, 6, v34                              // 0000001541B0: 324A4486
	v_lshrrev_b32_e32 v38, 14, v34                             // 0000001541B4: 324C448E
	v_lshrrev_b32_e32 v34, 22, v34                             // 0000001541B8: 32444496
	v_and_b32_e32 v39, 0xff, v35                               // 0000001541BC: 364E46FF 000000FF
	v_lshlrev_b32_e32 v36, 2, v36                              // 0000001541C4: 30484882
	v_and_b32_e32 v37, 0x3fc, v37                              // 0000001541C8: 364A4AFF 000003FC
	v_and_b32_e32 v38, 0x3fc, v38                              // 0000001541D0: 364C4CFF 000003FC
	v_and_b32_e32 v34, 0x3fc, v34                              // 0000001541D8: 364444FF 000003FC
	v_lshlrev_b32_e32 v39, 2, v39                              // 0000001541E0: 304E4E82
	s_clause 0x2                                               // 0000001541E4: BF850002
	global_load_b32 v36, v36, s[10:11]                         // 0000001541E8: DC520000 240A0024
	global_load_b32 v37, v37, s[10:11]                         // 0000001541F0: DC520000 250A0025
	global_load_b32 v38, v38, s[10:11]                         // 0000001541F8: DC520000 260A0026
	v_lshrrev_b32_e32 v40, 6, v35                              // 000000154200: 32504686
	s_clause 0x1                                               // 000000154204: BF850001
	global_load_b32 v34, v34, s[10:11]                         // 000000154208: DC520000 220A0022
	global_load_b32 v39, v39, s[10:11]                         // 000000154210: DC520000 270A0027
	v_lshrrev_b32_e32 v41, 14, v35                             // 000000154218: 3252468E
	v_lshrrev_b32_e32 v35, 22, v35                             // 00000015421C: 32464696
	v_and_b32_e32 v40, 0x3fc, v40                              // 000000154220: 365050FF 000003FC
	s_waitcnt vmcnt(5)                                         // 000000154228: BF8917F7
	v_bfe_u32 v44, v31, 21, 8                                  // 00000015422C: D610002C 02212B1F
	v_bfe_u32 v42, v31, 14, 8                                  // 000000154234: D610002A 02211D1F
	v_and_b32_e32 v41, 0x3fc, v41                              // 00000015423C: 365252FF 000003FC
	v_and_b32_e32 v35, 0x3fc, v35                              // 000000154244: 364646FF 000003FC
	s_clause 0x2                                               // 00000015424C: BF850002
	global_load_b32 v40, v40, s[10:11]                         // 000000154250: DC520000 280A0028
	global_load_b32 v41, v41, s[10:11]                         // 000000154258: DC520000 290A0029
	global_load_b32 v35, v35, s[10:11]                         // 000000154260: DC520000 230A0023
	global_load_d16_b16 v4, v[32:33], off                      // 000000154268: DC820000 047C0020
	v_and_b32_e32 v32, 0xff, v31                               // 000000154270: 36403EFF 000000FF
	v_bfe_u32 v33, v31, 7, 8                                   // 000000154278: D6100021 02210F1F
	v_bcnt_u32_b32 v47, v44, 0                                 // 000000154280: D71E002F 0001012C
	v_bcnt_u32_b32 v46, v42, 0                                 // 000000154288: D71E002E 0001012A
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 000000154290: BF870214
	v_bcnt_u32_b32 v43, v32, 0                                 // 000000154294: D71E002B 00010120
	v_bcnt_u32_b32 v45, v33, 0                                 // 00000015429C: D71E002D 00010121
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 0000001542A4: BF870214
	v_and_b32_e32 v47, 1, v47                                  // 0000001542A8: 365E5E81
	v_and_b32_e32 v46, 1, v46                                  // 0000001542AC: 365C5C81
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 0000001542B0: BF870214
	v_and_b32_e32 v43, 1, v43                                  // 0000001542B4: 36565681
	v_and_b32_e32 v45, 1, v45                                  // 0000001542B8: 365A5A81
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)// 0000001542BC: BF870193
	v_lshlrev_b32_e32 v46, 7, v46                              // 0000001542C0: 305C5C87
	v_lshlrev_b32_e32 v43, 7, v43                              // 0000001542C4: 30565687
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)// 0000001542C8: BF870193
	v_lshlrev_b32_e32 v45, 7, v45                              // 0000001542CC: 305A5A87
	v_xor_b32_e32 v42, v46, v42                                // 0000001542D0: 3A54552E
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_4)// 0000001542D4: BF870223
	v_xor_b32_e32 v32, v43, v32                                // 0000001542D8: 3A40412B
	v_lshlrev_b32_e32 v43, 7, v47                              // 0000001542DC: 30565E87
	v_xor_b32_e32 v33, v45, v33                                // 0000001542E0: 3A42432D
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 0000001542E4: BF870214
	v_mul_lo_u32 v42, 0x1010101, v42                           // 0000001542E8: D72C002A 000254FF 01010101
	v_mul_lo_u32 v32, 0x1010101, v32                           // 0000001542F4: D72C0020 000240FF 01010101
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 000000154300: BF870214
	v_xor_b32_e32 v43, v43, v44                                // 000000154304: 3A56592B
	v_mul_lo_u32 v33, 0x1010101, v33                           // 000000154308: D72C0021 000242FF 01010101
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000154314: BF870194
	v_and_b32_e32 v46, 0x8040201, v42                          // 000000154318: 365C54FF 08040201
	v_mul_lo_u32 v43, 0x1010101, v43                           // 000000154320: D72C002B 000256FF 01010101
	v_and_b32_e32 v44, 0x8040201, v32                          // 00000015432C: 365840FF 08040201
	v_and_b32_e32 v32, 0x80402010, v32                         // 000000154334: 364040FF 80402010
	v_and_b32_e32 v45, 0x8040201, v33                          // 00000015433C: 365A42FF 08040201
	v_and_b32_e32 v33, 0x80402010, v33                         // 000000154344: 364242FF 80402010
	v_and_b32_e32 v42, 0x80402010, v42                         // 00000015434C: 365454FF 80402010
	v_add_nc_u32_e32 v44, 0x7f7f7f7f, v44                      // 000000154354: 4A5858FF 7F7F7F7F
	v_add_nc_u32_e32 v32, 0x7f7f7f7f, v32                      // 00000015435C: 4A4040FF 7F7F7F7F
	v_add_nc_u32_e32 v45, 0x7f7f7f7f, v45                      // 000000154364: 4A5A5AFF 7F7F7F7F
	v_add_nc_u32_e32 v33, 0x7f7f7f7f, v33                      // 00000015436C: 4A4242FF 7F7F7F7F
	v_add_nc_u32_e32 v46, 0x7f7f7f7f, v46                      // 000000154374: 4A5C5CFF 7F7F7F7F
	v_lshrrev_b32_e32 v44, 7, v44                              // 00000015437C: 32585887
	v_lshrrev_b32_e32 v32, 7, v32                              // 000000154380: 32404087
	v_lshrrev_b32_e32 v45, 7, v45                              // 000000154384: 325A5A87
	v_lshrrev_b32_e32 v33, 7, v33                              // 000000154388: 32424287
	v_and_b32_e32 v47, 0x8040201, v43                          // 00000015438C: 365E56FF 08040201
	v_and_b32_e32 v44, 0x1010101, v44                          // 000000154394: 365858FF 01010101
	v_and_b32_e32 v32, 0x1010101, v32                          // 00000015439C: 364040FF 01010101
	v_and_b32_e32 v45, 0x1010101, v45                          // 0000001543A4: 365A5AFF 01010101
	v_add_nc_u32_e32 v42, 0x7f7f7f7f, v42                      // 0000001543AC: 4A5454FF 7F7F7F7F
	v_lshrrev_b32_e32 v46, 7, v46                              // 0000001543B4: 325C5C87
	v_mul_lo_u32 v44, 0xff, v44                                // 0000001543B8: D72C002C 000258FF 000000FF
	v_mul_lo_u32 v32, 0xff, v32                                // 0000001543C4: D72C0020 000240FF 000000FF
	v_and_b32_e32 v33, 0x1010101, v33                          // 0000001543D0: 364242FF 01010101
	v_mul_lo_u32 v45, 0xff, v45                                // 0000001543D8: D72C002D 00025AFF 000000FF
	v_and_b32_e32 v43, 0x80402010, v43                         // 0000001543E4: 365656FF 80402010
	v_add_nc_u32_e32 v47, 0x7f7f7f7f, v47                      // 0000001543EC: 4A5E5EFF 7F7F7F7F
	v_lshrrev_b32_e32 v42, 7, v42                              // 0000001543F4: 32545487
	v_and_b32_e32 v46, 0x1010101, v46                          // 0000001543F8: 365C5CFF 01010101
	v_and_b32_e32 v48, 0x7f7f7f7f, v44                         // 000000154400: 366058FF 7F7F7F7F
	v_and_b32_e32 v49, 0x7f7f7f7f, v32                         // 000000154408: 366240FF 7F7F7F7F
	v_mul_lo_u32 v33, 0xff, v33                                // 000000154410: D72C0021 000242FF 000000FF
	v_and_b32_e32 v50, 0x7f7f7f7f, v45                         // 00000015441C: 36645AFF 7F7F7F7F
	v_add_nc_u32_e32 v43, 0x7f7f7f7f, v43                      // 000000154424: 4A5656FF 7F7F7F7F
	v_lshrrev_b32_e32 v47, 7, v47                              // 00000015442C: 325E5E87
	v_and_b32_e32 v42, 0x1010101, v42                          // 000000154430: 365454FF 01010101
	v_mul_lo_u32 v46, 0xff, v46                                // 000000154438: D72C002E 00025CFF 000000FF
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_3) | instid1(VALU_DEP_4)// 000000154444: BF870244
	v_lshrrev_b32_e32 v43, 7, v43                              // 000000154448: 32565687
	v_and_b32_e32 v51, 0x7f7f7f7f, v33                         // 00000015444C: 366642FF 7F7F7F7F
	v_and_b32_e32 v47, 0x1010101, v47                          // 000000154454: 365E5EFF 01010101
	v_mul_lo_u32 v42, 0xff, v42                                // 00000015445C: D72C002A 000254FF 000000FF
	v_and_b32_e32 v43, 0x1010101, v43                          // 000000154468: 365656FF 01010101
	v_and_b32_e32 v52, 0x7f7f7f7f, v46                         // 000000154470: 36685CFF 7F7F7F7F
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000154478: BF870194
	v_mul_lo_u32 v47, 0xff, v47                                // 00000015447C: D72C002F 00025EFF 000000FF
	v_mul_lo_u32 v43, 0xff, v43                                // 000000154488: D72C002B 000256FF 000000FF
	v_and_b32_e32 v53, 0x7f7f7f7f, v42                         // 000000154494: 366A54FF 7F7F7F7F
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000015449C: BF870193
	v_and_b32_e32 v54, 0x7f7f7f7f, v47                         // 0000001544A0: 366C5EFF 7F7F7F7F
	v_and_b32_e32 v55, 0x7f7f7f7f, v43                         // 0000001544A8: 366E56FF 7F7F7F7F
	s_waitcnt vmcnt(7)                                         // 0000001544B0: BF891FF7
	v_xor_b32_e32 v32, v32, v37                                // 0000001544B4: 3A404B20
	v_xor_b32_e32 v44, v44, v36                                // 0000001544B8: 3A58492C
	v_and_b32_e32 v36, 0x80808080, v36                         // 0000001544BC: 364848FF 80808080
	s_waitcnt vmcnt(6)                                         // 0000001544C4: BF891BF7
	v_xor_b32_e32 v45, v45, v38                                // 0000001544C8: 3A5A4D2D
	v_and_b32_e32 v37, 0x80808080, v37                         // 0000001544CC: 364A4AFF 80808080
	v_or_b32_e32 v32, 0x80808080, v32                          // 0000001544D4: 384040FF 80808080
	v_or_b32_e32 v44, 0x80808080, v44                          // 0000001544DC: 385858FF 80808080
	s_waitcnt vmcnt(5)                                         // 0000001544E4: BF8917F7
	v_xor_b32_e32 v33, v33, v34                                // 0000001544E8: 3A424521
	v_or_b32_e32 v45, 0x80808080, v45                          // 0000001544EC: 385A5AFF 80808080
	v_and_b32_e32 v38, 0x80808080, v38                         // 0000001544F4: 364C4CFF 80808080
	v_sub_nc_u32_e32 v32, v32, v49                             // 0000001544FC: 4C406320
	v_sub_nc_u32_e32 v44, v44, v48                             // 000000154500: 4C58612C
	s_waitcnt vmcnt(4)                                         // 000000154504: BF8913F7
	v_xor_b32_e32 v46, v46, v39                                // 000000154508: 3A5C4F2E
	v_or_b32_e32 v33, 0x80808080, v33                          // 00000015450C: 384242FF 80808080
	v_and_b32_e32 v34, 0x80808080, v34                         // 000000154514: 364444FF 80808080
	v_xor3_b32 v32, v37, v32, 0x80808080                       // 00000015451C: D6400020 03FE4125 80808080
	v_xor3_b32 v36, v36, v44, 0x80808080                       // 000000154528: D6400024 03FE5924 80808080
	v_sub_nc_u32_e32 v44, v45, v50                             // 000000154534: 4C58652D
	s_waitcnt vmcnt(3)                                         // 000000154538: BF890FF7
	v_xor_b32_e32 v37, v42, v40                                // 00000015453C: 3A4A512A
	v_or_b32_e32 v42, 0x80808080, v46                          // 000000154540: 38545CFF 80808080
	v_sub_nc_u32_e32 v33, v33, v51                             // 000000154548: 4C426721
	v_dot4_i32_iu8 v36, v36, v5, 0 neg_lo:[1,1,0]              // 00000015454C: CC164024 7A020B24
	v_xor3_b32 v38, v38, v44, 0x80808080                       // 000000154554: D6400026 03FE5926 80808080
	v_and_b32_e32 v39, 0x80808080, v39                         // 000000154560: 364E4EFF 80808080
	v_or_b32_e32 v37, 0x80808080, v37                          // 000000154568: 384A4AFF 80808080
	v_xor3_b32 v33, v34, v33, 0x80808080                       // 000000154570: D6400021 03FE4322 80808080
	v_dot4_i32_iu8 v32, v32, v6, v36 neg_lo:[1,1,0]            // 00000015457C: CC164020 7C920D20
	v_and_b32_e32 v36, 0x80808080, v40                         // 000000154584: 364850FF 80808080
	v_sub_nc_u32_e32 v40, v42, v52                             // 00000015458C: 4C50692A
	s_waitcnt vmcnt(2)                                         // 000000154590: BF890BF7
	v_xor_b32_e32 v34, v47, v41                                // 000000154594: 3A44532F
	v_sub_nc_u32_e32 v37, v37, v53                             // 000000154598: 4C4A6B25
	v_dot4_i32_iu8 v32, v38, v7, v32 neg_lo:[1,1,0]            // 00000015459C: CC164020 7C820F26
	s_waitcnt vmcnt(1)                                         // 0000001545A4: BF8907F7
	v_xor_b32_e32 v38, v43, v35                                // 0000001545A8: 3A4C472B
	v_xor3_b32 v39, v39, v40, 0x80808080                       // 0000001545AC: D6400027 03FE5127 80808080
	v_and_b32_e32 v35, 0x80808080, v35                         // 0000001545B8: 364646FF 80808080
	v_xor3_b32 v36, v36, v37, 0x80808080                       // 0000001545C0: D6400024 03FE4B24 80808080
	v_dot4_i32_iu8 v32, v33, v0, v32 neg_lo:[1,1,0]            // 0000001545CC: CC164020 7C820121
	v_or_b32_e32 v33, 0x80808080, v34                          // 0000001545D4: 384244FF 80808080
	v_and_b32_e32 v34, 0x80808080, v41                         // 0000001545DC: 364452FF 80808080
	v_or_b32_e32 v38, 0x80808080, v38                          // 0000001545E4: 384C4CFF 80808080
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 0000001545EC: BF870214
	v_dot4_i32_iu8 v32, v39, v1, v32 neg_lo:[1,1,0]            // 0000001545F0: CC164020 7C820327
	v_sub_nc_u32_e32 v33, v33, v54                             // 0000001545F8: 4C426D21
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)// 0000001545FC: BF870193
	v_sub_nc_u32_e32 v37, v38, v55                             // 000000154600: 4C4A6F26
	v_dot4_i32_iu8 v32, v36, v2, v32 neg_lo:[1,1,0]            // 000000154604: CC164020 7C820524
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000015460C: BF870193
	v_xor3_b32 v33, v34, v33, 0x80808080                       // 000000154610: D6400021 03FE4322 80808080
	v_xor3_b32 v34, v35, v37, 0x80808080                       // 00000015461C: D6400022 03FE4B23 80808080
	v_lshrrev_b32_e32 v35, 28, v31                             // 000000154628: 32463E9C
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000015462C: BF870093
	v_dot4_i32_iu8 v32, v33, v3, v32 neg_lo:[1,1,0]            // 000000154630: CC164020 7C820721
	v_dot4_i32_iu8 v34, v34, v21, v32 neg_lo:[1,1,0]           // 000000154638: CC164022 7C822B22
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154640: BF870091
	v_lshrrev_b32_e32 v32, 31, v34                             // 000000154644: 3240449F
	v_add_nc_u32_e32 v32, v34, v32                             // 000000154648: 4A404122
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000015464C: BF870091
	v_ashrrev_i32_e32 v31, 1, v32                              // 000000154650: 343E4081
	v_mad_u64_u32 v[32:33], null, v34, v35, v[31:32]           // 000000154654: D6FE7C20 047E4722
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000015465C: BF870091
	v_lshrrev_b32_e32 v31, 31, v32                             // 000000154660: 323E409F
	v_add_nc_u32_e32 v31, v32, v31                             // 000000154664: 4A3E3F20
	s_waitcnt vmcnt(0)                                         // 000000154668: BF8903F7
	v_cvt_f32_f16_e32 v32, v4.l                                // 00000015466C: 7E401704
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000154670: BF870112
	v_ashrrev_i32_e32 v31, 1, v31                              // 000000154674: 343E3E81
	v_mul_f32_e32 v32, v22, v32                                // 000000154678: 10404116
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000015467C: BF870092
	v_cvt_f32_i32_e32 v31, v31                                 // 000000154680: 7E3E0B1F
	v_fmac_f32_e32 v15, v32, v31                               // 000000154684: 561E3F20
	s_branch 64866                                             // 000000154688: BFA0FD62 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x314>
	s_or_b32 exec_lo, exec_lo, s16                             // 00000015468C: 8C7E107E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000154690: BF870009
	s_or_b32 exec_lo, exec_lo, s31                             // 000000154694: 8C7E1F7E
	s_waitcnt vmcnt(0)                                         // 000000154698: BF8903F7
	buffer_gl0_inv                                             // 00000015469C: E0AC0000 00000000
	s_mov_b32 s3, exec_lo                                      // 0000001546A4: BE83007E
	v_cmpx_eq_u32_e32 0, v13                                   // 0000001546A8: 7D941A80
	s_cbranch_execz 405                                        // 0000001546AC: BFA50195 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1404>
	v_mbcnt_lo_u32_b32 v1, -1, 0                               // 0000001546B0: D71F0001 000100C1
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 0000001546B8: BF8701B1
	v_xor_b32_e32 v0, 16, v1                                   // 0000001546BC: 3A000290
	v_xor_b32_e32 v3, 8, v1                                    // 0000001546C0: 3A060288
	v_xor_b32_e32 v4, 4, v1                                    // 0000001546C4: 3A080284
	v_cmp_gt_i32_e32 vcc_lo, 32, v0                            // 0000001546C8: 7C8800A0
	v_cndmask_b32_e32 v0, v1, v0, vcc_lo                       // 0000001546CC: 02000101
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_2) | instid1(VALU_DEP_2)// 0000001546D0: BF870134
	v_cmp_gt_i32_e32 vcc_lo, 32, v3                            // 0000001546D4: 7C8806A0
	v_cndmask_b32_e32 v3, v1, v3, vcc_lo                       // 0000001546D8: 02060701
	v_cmp_gt_i32_e32 vcc_lo, 32, v4                            // 0000001546DC: 7C8808A0
	v_lshlrev_b32_e32 v3, 2, v3                                // 0000001546E0: 30060682
	v_lshlrev_b32_e32 v0, 2, v0                                // 0000001546E4: 30000082
	v_cndmask_b32_e32 v4, v1, v4, vcc_lo                       // 0000001546E8: 02080901
	ds_bpermute_b32 v2, v0, v16                                // 0000001546EC: DACC0000 02001000
	s_waitcnt lgkmcnt(0)                                       // 0000001546F4: BF89FC07
	v_add_f32_e32 v2, v16, v2                                  // 0000001546F8: 06040510
	ds_bpermute_b32 v5, v3, v2                                 // 0000001546FC: DACC0000 05000203
	s_waitcnt lgkmcnt(0)                                       // 000000154704: BF89FC07
	v_add_f32_e32 v2, v2, v5                                   // 000000154708: 06040B02
	v_xor_b32_e32 v5, 2, v1                                    // 00000015470C: 3A0A0282
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000154710: BF8700A1
	v_cmp_gt_i32_e32 vcc_lo, 32, v5                            // 000000154714: 7C880AA0
	v_cndmask_b32_e32 v5, v1, v5, vcc_lo                       // 000000154718: 020A0B01
	v_lshlrev_b32_e32 v5, 2, v5                                // 00000015471C: 300A0A82
	v_lshlrev_b32_e32 v4, 2, v4                                // 000000154720: 30080882
	ds_bpermute_b32 v6, v4, v2                                 // 000000154724: DACC0000 06000204
	s_waitcnt lgkmcnt(0)                                       // 00000015472C: BF89FC07
	v_add_f32_e32 v2, v2, v6                                   // 000000154730: 06040D02
	v_xor_b32_e32 v6, 1, v1                                    // 000000154734: 3A0C0281
	ds_bpermute_b32 v7, v5, v2                                 // 000000154738: DACC0000 07000205
	v_cmp_gt_i32_e32 vcc_lo, 32, v6                            // 000000154740: 7C880CA0
	v_cndmask_b32_e32 v1, v1, v6, vcc_lo                       // 000000154744: 02020D01
	v_cmp_ne_u32_e32 vcc_lo, 1, v14                            // 000000154748: 7C9A1C81
	s_delay_alu instid0(VALU_DEP_2)                            // 00000015474C: BF870002
	v_lshlrev_b32_e32 v6, 2, v1                                // 000000154750: 300C0282
	s_waitcnt lgkmcnt(0)                                       // 000000154754: BF89FC07
	v_add_f32_e32 v1, v2, v7                                   // 000000154758: 06020F02
	ds_bpermute_b32 v2, v6, v1                                 // 00000015475C: DACC0000 02000106
	s_cbranch_vccnz 20                                         // 000000154764: BFA40014 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xeb8>
	ds_bpermute_b32 v0, v0, v15                                // 000000154768: DACC0000 00000F00
	s_waitcnt lgkmcnt(0)                                       // 000000154770: BF89FC07
	v_add_f32_e32 v0, v15, v0                                  // 000000154774: 0600010F
	ds_bpermute_b32 v3, v3, v0                                 // 000000154778: DACC0000 03000003
	s_waitcnt lgkmcnt(0)                                       // 000000154780: BF89FC07
	v_add_f32_e32 v0, v0, v3                                   // 000000154784: 06000700
	ds_bpermute_b32 v3, v4, v0                                 // 000000154788: DACC0000 03000004
	s_waitcnt lgkmcnt(0)                                       // 000000154790: BF89FC07
	v_add_f32_e32 v0, v0, v3                                   // 000000154794: 06000700
	ds_bpermute_b32 v3, v5, v0                                 // 000000154798: DACC0000 03000005
	s_waitcnt lgkmcnt(0)                                       // 0000001547A0: BF89FC07
	v_add_f32_e32 v0, v0, v3                                   // 0000001547A4: 06000700
	ds_bpermute_b32 v3, v6, v0                                 // 0000001547A8: DACC0000 03000006
	s_waitcnt lgkmcnt(0)                                       // 0000001547B0: BF89FC07
	v_add_f32_e32 v15, v0, v3                                  // 0000001547B4: 061E0700
	v_cmp_eq_u32_e32 vcc_lo, 0, v10                            // 0000001547B8: 7C941480
	s_and_b32 exec_lo, exec_lo, vcc_lo                         // 0000001547BC: 8B7E6A7E
	s_cbranch_execz 336                                        // 0000001547C0: BFA50150 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1404>
	s_waitcnt lgkmcnt(0)                                       // 0000001547C4: BF89FC07
	v_add_f32_e32 v0, v1, v2                                   // 0000001547C8: 06000501
	v_cmp_ne_u32_e32 vcc_lo, 1, v14                            // 0000001547CC: 7C9A1C81
	s_delay_alu instid0(VALU_DEP_2)                            // 0000001547D0: BF870002
	v_add_f32_e32 v0, v12, v0                                  // 0000001547D4: 0600010C
	s_cbranch_vccnz 312                                        // 0000001547D8: BFA40138 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x13bc>
	v_add_f32_e32 v1, v11, v15                                 // 0000001547DC: 06021F0B
	s_cmp_lt_i32 s12, 3                                        // 0000001547E0: BF04830C
	s_mov_b32 s3, 0                                            // 0000001547E4: BE830080
	s_cbranch_scc1 75                                          // 0000001547E8: BFA2004B <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1018>
	s_cmp_gt_i32 s12, 5                                        // 0000001547EC: BF02850C
	s_cbranch_scc0 76                                          // 0000001547F0: BFA1004C <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1024>
	s_cmp_eq_u32 s12, 6                                        // 0000001547F4: BF06860C
	s_cbranch_scc0 77                                          // 0000001547F8: BFA1004D <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1030>
	v_max_f32_e32 v2, v1, v1                                   // 0000001547FC: 20040301
	v_max_f32_e64 v3, s13, s13                                 // 000000154800: D5100003 00001A0D
	s_mov_b32 s8, 0                                            // 000000154808: BE880080
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000015480C: BF870091
	v_min_f32_e32 v2, v2, v3                                   // 000000154810: 1E040702
	v_mul_f32_e32 v4, 0xbfb8aa3b, v2                           // 000000154814: 100804FF BFB8AA3B
	v_cmp_nlt_f32_e32 vcc_lo, 0x42ce8ed0, v2                   // 00000015481C: 7C3C04FF 42CE8ED0
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000154824: BF8700A2
	v_fma_f32 v5, 0xbfb8aa3b, v2, -v4                          // 000000154828: D6130005 841204FF BFB8AA3B
	v_rndne_f32_e32 v6, v4                                     // 000000154834: 7E0C4704
	v_dual_fmamk_f32 v5, v2, 0xb2a5705f, v5 :: v_dual_sub_f32 v4, v4, v6// 000000154838: C88A0B02 05040D04 B2A5705F
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000154844: BF870121
	v_add_f32_e32 v4, v4, v5                                   // 000000154848: 06080B04
	v_cvt_i32_f32_e32 v5, v6                                   // 00000015484C: 7E0A1106
	v_exp_f32_e32 v4, v4                                       // 000000154850: 7E084B04
	s_waitcnt_depctr 0xfff                                     // 000000154854: BF880FFF
	v_ldexp_f32 v4, v4, v5                                     // 000000154858: D71C0004 00020B04
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000154860: BF870121
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo                        // 000000154864: 02080880
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2b17218, v2                   // 000000154868: 7C3604FF C2B17218
	v_cndmask_b32_e32 v4, 0x7f800000, v4, vcc_lo               // 000000154870: 020808FF 7F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154878: BF870091
	v_add_f32_e32 v4, 1.0, v4                                  // 00000015487C: 060808F2
	v_div_scale_f32 v5, null, v4, v4, v2                       // 000000154880: D6FC7C05 040A0904
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000154888: BF8700B1
	v_rcp_f32_e32 v6, v5                                       // 00000015488C: 7E0C5505
	s_waitcnt_depctr 0xfff                                     // 000000154890: BF880FFF
	v_fma_f32 v7, -v5, v6, 1.0                                 // 000000154894: D6130007 23CA0D05
	v_fmac_f32_e32 v6, v7, v6                                  // 00000015489C: 560C0D07
	v_div_scale_f32 v7, vcc_lo, v2, v4, v2                     // 0000001548A0: D6FC6A07 040A0902
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001548A8: BF870091
	v_mul_f32_e32 v8, v7, v6                                   // 0000001548AC: 10100D07
	v_fma_f32 v9, -v5, v8, v7                                  // 0000001548B0: D6130009 241E1105
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000001548B8: BF870121
	v_fmac_f32_e32 v8, v9, v6                                  // 0000001548BC: 56100D09
	v_max_f32_e64 v9, -s13, -s13                               // 0000001548C0: D5100009 60001A0D
	v_fma_f32 v5, -v5, v8, v7                                  // 0000001548C8: D6130005 241E1105
	v_max_f32_e32 v7, v0, v0                                   // 0000001548D0: 200E0100
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000001548D4: BF870112
	v_div_fmas_f32 v5, v5, v6, v8                              // 0000001548D8: D6370005 04220D05
	v_minmax_f32 v3, v7, v3, v9                                // 0000001548E0: D65F0003 04260707
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001548E8: BF870092
	v_div_fixup_f32 v2, v5, v4, v2                             // 0000001548EC: D6270002 040A0905
	v_mul_f32_e32 v2, v3, v2                                   // 0000001548F4: 10040503
	s_branch 14                                                // 0000001548F8: BFA0000E <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1034>
	s_clause 0x1                                               // 0000001548FC: BF850001
	s_load_b128 s[36:39], s[0:1], 0x70                         // 000000154900: F4080900 F8000070
	s_load_b128 s[16:19], s[0:1], 0x98                         // 000000154908: F4080400 F8000098
	s_branch 64531                                             // 000000154910: BFA0FC13 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x60>
	s_branch 64550                                             // 000000154914: BFA0FC26 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xb0>
	s_mov_b32 s8, 0                                            // 000000154918: BE880080
	s_cbranch_execnz 78                                        // 00000015491C: BFA6004E <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1158>
	s_branch 140                                               // 000000154920: BFA0008C <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1254>
	s_mov_b32 s8, 0                                            // 000000154924: BE880080
	s_cbranch_execnz 3                                         // 000000154928: BFA60003 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1038>
	s_branch 71                                                // 00000015492C: BFA00047 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x114c>
	s_mov_b32 s8, -1                                           // 000000154930: BE8800C1
	s_branch 69                                                // 000000154934: BFA00045 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x114c>
	s_cmp_eq_u32 s12, 3                                        // 000000154938: BF06830C
	s_cbranch_scc0 68                                          // 00000015493C: BFA10044 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1150>
	v_max_f32_e32 v2, v1, v1                                   // 000000154940: 20040301
	s_mov_b32 s8, 0xc0e00000                                   // 000000154944: BE8800FF C0E00000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000015494C: BF870091
	v_min_f32_e32 v2, 0x40e00000, v2                           // 000000154950: 1E0404FF 40E00000
	v_mul_f32_e32 v3, 0xbfd9db23, v2                           // 000000154958: 100604FF BFD9DB23
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154960: BF870091
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3                           // 000000154964: 100806FF 3FB8AA3B
	v_fma_f32 v5, 0x3fb8aa3b, v3, -v4                          // 00000015496C: D6130005 841206FF 3FB8AA3B
	v_rndne_f32_e32 v6, v4                                     // 000000154978: 7E0C4704
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000015497C: BF870091
	v_dual_fmamk_f32 v5, v3, 0x32a5705f, v5 :: v_dual_sub_f32 v4, v4, v6// 000000154980: C88A0B03 05040D04 32A5705F
	v_add_f32_e32 v4, v4, v5                                   // 00000015498C: 06080B04
	v_cvt_i32_f32_e32 v5, v6                                   // 000000154990: 7E0A1106
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v3                   // 000000154994: 7C3606FF C2CE8ED0
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000015499C: BF8700B3
	v_exp_f32_e32 v4, v4                                       // 0000001549A0: 7E084B04
	s_waitcnt_depctr 0xfff                                     // 0000001549A4: BF880FFF
	v_ldexp_f32 v4, v4, v5                                     // 0000001549A8: D71C0004 00020B04
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo                        // 0000001549B0: 02080880
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v3                   // 0000001549B4: 7C3C06FF 42B17218
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001549BC: BF870092
	v_cndmask_b32_e32 v3, 0x7f800000, v4, vcc_lo               // 0000001549C0: 020608FF 7F800000
	v_add_f32_e32 v3, 1.0, v3                                  // 0000001549C8: 060606F2
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000001549CC: BF870121
	v_div_scale_f32 v4, null, v3, v3, v2                       // 0000001549D0: D6FC7C04 040A0703
	v_div_scale_f32 v7, vcc_lo, v2, v3, v2                     // 0000001549D8: D6FC6A07 040A0702
	v_rcp_f32_e32 v5, v4                                       // 0000001549E0: 7E0A5504
	s_waitcnt_depctr 0xfff                                     // 0000001549E4: BF880FFF
	v_fma_f32 v6, -v4, v5, 1.0                                 // 0000001549E8: D6130006 23CA0B04
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001549F0: BF870091
	v_fmac_f32_e32 v5, v6, v5                                  // 0000001549F4: 560A0B06
	v_mul_f32_e32 v6, v7, v5                                   // 0000001549F8: 100C0B07
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001549FC: BF870091
	v_fma_f32 v8, -v4, v6, v7                                  // 000000154A00: D6130008 241E0D04
	v_fmac_f32_e32 v6, v8, v5                                  // 000000154A08: 560C0B08
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154A0C: BF870091
	v_fma_f32 v4, -v4, v6, v7                                  // 000000154A10: D6130004 241E0D04
	v_div_fmas_f32 v4, v4, v5, v6                              // 000000154A18: D6370004 041A0B04
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000154A20: BF8700A1
	v_div_fixup_f32 v2, v4, v3, v2                             // 000000154A24: D6270002 040A0704
	v_max_f32_e32 v7, v0, v0                                   // 000000154A2C: 200E0100
	v_minmax_f32 v5, v7, 0x40e00000, s8                        // 000000154A30: D65F0005 0021FF07 40E00000
	s_mov_b32 s8, 0                                            // 000000154A3C: BE880080
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154A40: BF870091
	v_add_f32_e32 v3, 1.0, v5                                  // 000000154A44: 06060AF2
	v_mul_f32_e32 v2, v3, v2                                   // 000000154A48: 10040503
	s_branch 65                                                // 000000154A4C: BFA00041 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1254>
	s_mov_b32 s8, -1                                           // 000000154A50: BE8800C1
	s_branch 63                                                // 000000154A54: BFA0003F <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1254>
	s_cmp_gt_i32 s12, 1                                        // 000000154A58: BF02810C
	s_cbranch_scc0 53                                          // 000000154A5C: BFA10035 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1234>
	v_mul_f32_e32 v2, 0xbfb8aa3b, v1                           // 000000154A60: 100402FF BFB8AA3B
	v_cmp_nlt_f32_e32 vcc_lo, 0x42ce8ed0, v1                   // 000000154A68: 7C3C02FF 42CE8ED0
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000154A70: BF870122
	v_rndne_f32_e32 v3, v2                                     // 000000154A74: 7E064702
	v_fma_f32 v4, 0xbfb8aa3b, v1, -v2                          // 000000154A78: D6130004 840A02FF BFB8AA3B
	v_sub_f32_e32 v2, v2, v3                                   // 000000154A84: 08040702
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000154A88: BF870122
	v_fmamk_f32 v4, v1, 0xb2a5705f, v4                         // 000000154A8C: 58080901 B2A5705F
	v_cvt_i32_f32_e32 v3, v3                                   // 000000154A94: 7E061103
	v_add_f32_e32 v2, v2, v4                                   // 000000154A98: 06040902
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000154A9C: BF8700B1
	v_exp_f32_e32 v2, v2                                       // 000000154AA0: 7E044B02
	s_waitcnt_depctr 0xfff                                     // 000000154AA4: BF880FFF
	v_ldexp_f32 v2, v2, v3                                     // 000000154AA8: D71C0002 00020702
	v_cndmask_b32_e32 v2, 0, v2, vcc_lo                        // 000000154AB0: 02040480
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2b17218, v1                   // 000000154AB4: 7C3602FF C2B17218
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154ABC: BF870092
	v_cndmask_b32_e32 v2, 0x7f800000, v2, vcc_lo               // 000000154AC0: 020404FF 7F800000
	v_add_f32_e32 v2, 1.0, v2                                  // 000000154AC8: 060404F2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154ACC: BF870091
	v_div_scale_f32 v3, null, v2, v2, v1                       // 000000154AD0: D6FC7C03 04060502
	v_rcp_f32_e32 v4, v3                                       // 000000154AD8: 7E085503
	s_waitcnt_depctr 0xfff                                     // 000000154ADC: BF880FFF
	v_fma_f32 v5, -v3, v4, 1.0                                 // 000000154AE0: D6130005 23CA0903
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000154AE8: BF8700A1
	v_fmac_f32_e32 v4, v5, v4                                  // 000000154AEC: 56080905
	v_div_scale_f32 v5, vcc_lo, v1, v2, v1                     // 000000154AF0: D6FC6A05 04060501
	v_mul_f32_e32 v6, v5, v4                                   // 000000154AF8: 100C0905
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154AFC: BF870091
	v_fma_f32 v7, -v3, v6, v5                                  // 000000154B00: D6130007 24160D03
	v_fmac_f32_e32 v6, v7, v4                                  // 000000154B08: 560C0907
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154B0C: BF870091
	v_fma_f32 v3, -v3, v6, v5                                  // 000000154B10: D6130003 24160D03
	v_div_fmas_f32 v3, v3, v4, v6                              // 000000154B18: D6370003 041A0903
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154B20: BF870091
	v_div_fixup_f32 v2, v3, v2, v1                             // 000000154B24: D6270002 04060503
	v_mul_f32_e32 v2, v0, v2                                   // 000000154B2C: 10040500
	s_branch 1                                                 // 000000154B30: BFA00001 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1238>
	s_mov_b32 s3, -1                                           // 000000154B34: BE8300C1
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000154B38: BF870009
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 000000154B3C: 916A037E
	s_mov_b32 s3, 0                                            // 000000154B40: BE830080
	s_cbranch_vccnz 3                                          // 000000154B44: BFA40003 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1254>
	s_cmp_lg_u32 s12, 1                                        // 000000154B48: BF07810C
	s_mov_b32 s3, -1                                           // 000000154B4C: BE8300C1
	s_cselect_b32 s8, -1, 0                                    // 000000154B50: 980880C1
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000154B54: BF870009
	s_and_b32 vcc_lo, exec_lo, s8                              // 000000154B58: 8B6A087E
	s_cbranch_vccz 2                                           // 000000154B5C: BFA30002 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1268>
	v_mul_f32_e32 v2, v0, v1                                   // 000000154B60: 10040300
	s_mov_b32 s3, 0                                            // 000000154B64: BE830080
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000154B68: BF870009
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 000000154B6C: 916A037E
	s_cbranch_vccnz 80                                         // 000000154B70: BFA40050 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x13b4>
	v_mul_f32_e32 v2, 0x3d372713, v1                           // 000000154B74: 100402FF 3D372713
	v_mul_f32_e32 v3, 0x3f4c422a, v1                           // 000000154B7C: 100602FF 3F4C422A
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154B84: BF870092
	v_fma_f32 v2, v1, v2, 1.0                                  // 000000154B88: D6130002 03CA0501
	v_mul_f32_e32 v2, v3, v2                                   // 000000154B90: 10040503
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 000000154B94: BF8704A1
	v_cmp_ngt_f32_e64 s3, 0x3f200000, |v2|                     // 000000154B98: D41B0203 000204FF 3F200000
	s_and_saveexec_b32 s8, s3                                  // 000000154BA4: BE882003
	s_xor_b32 s3, exec_lo, s8                                  // 000000154BA8: 8D03087E
	s_cbranch_execz 34                                         // 000000154BAC: BFA50022 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1338>
	v_add_f32_e64 v3, |v2|, |v2|                               // 000000154BB0: D5030303 00020502
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000154BB8: BF870121
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3                           // 000000154BBC: 100806FF 3FB8AA3B
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v3                   // 000000154BC4: 7C3606FF C2CE8ED0
	v_rndne_f32_e32 v5, v4                                     // 000000154BCC: 7E0A4704
	v_fma_f32 v6, 0x3fb8aa3b, v3, -v4                          // 000000154BD0: D6130006 841206FF 3FB8AA3B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000154BDC: BF870112
	v_sub_f32_e32 v4, v4, v5                                   // 000000154BE0: 08080B04
	v_fmamk_f32 v6, v3, 0x32a5705f, v6                         // 000000154BE4: 580C0D03 32A5705F
	v_cvt_i32_f32_e32 v5, v5                                   // 000000154BEC: 7E0A1105
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154BF0: BF870092
	v_add_f32_e32 v4, v4, v6                                   // 000000154BF4: 06080D04
	v_exp_f32_e32 v4, v4                                       // 000000154BF8: 7E084B04
	s_waitcnt_depctr 0xfff                                     // 000000154BFC: BF880FFF
	v_ldexp_f32 v4, v4, v5                                     // 000000154C00: D71C0004 00020B04
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000154C08: BF870121
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo                        // 000000154C0C: 02080880
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v3                   // 000000154C10: 7C3C06FF 42B17218
	v_cndmask_b32_e32 v3, 0x7f800000, v4, vcc_lo               // 000000154C18: 020608FF 7F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154C20: BF870091
	v_add_f32_e32 v3, 1.0, v3                                  // 000000154C24: 060606F2
	v_rcp_f32_e32 v3, v3                                       // 000000154C28: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000154C2C: BF880FFF
	v_fma_f32 v3, v3, -2.0, 1.0                                // 000000154C30: D6130003 03C9EB03
	s_and_not1_saveexec_b32 s3, s3                             // 000000154C38: BE833003
	s_cbranch_execz 19                                         // 000000154C3C: BFA50013 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x138c>
	v_mul_f32_e32 v3, v2, v2                                   // 000000154C40: 10060502
	s_mov_b32 s8, 0xbbbac73d                                   // 000000154C44: BE8800FF BBBAC73D
	s_delay_alu instid0(VALU_DEP_1) | instid1(SALU_CYCLE_1)    // 000000154C4C: BF870481
	v_fmaak_f32 v4, s8, v3, 0x3ca908c9                         // 000000154C50: 5A080608 3CA908C9
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154C58: BF870091
	v_fmaak_f32 v4, v3, v4, 0xbd5c1c4e                         // 000000154C5C: 5A080903 BD5C1C4E
	v_fmaak_f32 v4, v3, v4, 0x3e088382                         // 000000154C64: 5A080903 3E088382
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154C6C: BF870091
	v_fmaak_f32 v4, v3, v4, 0xbeaaaa99                         // 000000154C70: 5A080903 BEAAAA99
	v_mul_f32_e64 v4, |v2|, v4                                 // 000000154C78: D5080104 00020902
	s_delay_alu instid0(VALU_DEP_1)                            // 000000154C80: BF870001
	v_fma_f32 v3, v3, v4, |v2|                                 // 000000154C84: D6130403 040A0903
	s_or_b32 exec_lo, exec_lo, s3                              // 000000154C8C: 8C7E037E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154C90: BF870091
	v_bfi_b32 v2, 0x7fffffff, v3, v2                           // 000000154C94: D6120002 040A06FF 7FFFFFFF
	v_dual_mul_f32 v1, 0.5, v1 :: v_dual_add_f32 v2, 1.0, v2   // 000000154CA0: C8C802F0 010204F2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154CA8: BF870091
	v_mul_f32_e32 v1, v1, v2                                   // 000000154CAC: 10020501
	v_mul_f32_e32 v2, v0, v1                                   // 000000154CB0: 10040300
	s_delay_alu instid0(VALU_DEP_1)                            // 000000154CB4: BF870001
	v_mov_b32_e32 v0, v2                                       // 000000154CB8: 7E000302
	s_load_b64 s[0:1], s[0:1], 0x68                            // 000000154CBC: F4040000 F8000068
	s_and_b32 s3, exec_lo, s5                                  // 000000154CC4: 8B03057E
	s_mul_i32 s3, s22, s4                                      // 000000154CC8: 96030416
	s_mul_i32 s33, s33, s18                                    // 000000154CCC: 96211221
	v_mov_b32_e32 v1, 0                                        // 000000154CD0: 7E020280
	s_waitcnt lgkmcnt(0)                                       // 000000154CD4: BF89FC07
	s_cselect_b32 s4, s7, s1                                   // 000000154CD8: 98040107
	s_cselect_b32 s5, s6, s0                                   // 000000154CDC: 98050006
	s_add_i32 s0, s3, s2                                       // 000000154CE0: 81000203
	s_mov_b32 s1, 0                                            // 000000154CE4: BE810080
	s_add_i32 s0, s0, s33                                      // 000000154CE8: 81002100
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000154CEC: BF870499
	s_lshl_b64 s[0:1], s[0:1], 2                               // 000000154CF0: 84808200
	s_add_u32 s0, s5, s0                                       // 000000154CF4: 80000005
	s_addc_u32 s1, s4, s1                                      // 000000154CF8: 82010104
	global_store_b32 v1, v0, s[0:1]                            // 000000154CFC: DC6A0000 00000001
	s_endpgm                                                   // 000000154D04: BFB00000
		...
