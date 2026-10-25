
build-hip-baseline/bin/libggml-hip.so.36.hipv4-amdgcn-amd-amdhsa--gfx1101:	file format elf64-amdgpu

Disassembly of section .text:

0000000000185e00 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj>:
	s_clause 0x2                                               // 000000185E00: BF850002
	s_load_b128 s[24:27], s[0:1], 0x48                         // 000000185E04: F4080600 F8000048
	s_load_b128 s[28:31], s[0:1], 0x20                         // 000000185E0C: F4080700 F8000020
	s_load_b256 s[8:15], s[0:1], null                          // 000000185E14: F40C0200 F8000000
	s_mov_b32 s20, s3                                          // 000000185E1C: BE940003
	s_waitcnt lgkmcnt(0)                                       // 000000185E20: BF89FC07
	s_cmp_lg_u64 s[24:25], 0                                   // 000000185E24: BF118018
	s_cbranch_scc0 1134                                        // 000000185E28: BFA1046E <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x11e4>
	s_load_b32 s3, s[0:1], 0xc4                                // 000000185E2C: F40000C0 F80000C4
	s_waitcnt lgkmcnt(0)                                       // 000000185E34: BF89FC07
	s_add_i32 s3, s3, -1                                       // 000000185E38: 8103C103
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000185E3C: BF870009
	s_cmp_eq_u32 s20, s3                                       // 000000185E40: BF060314
	s_cselect_b32 s5, -1, 0                                    // 000000185E44: 980580C1
	s_clause 0x1                                               // 000000185E48: BF850001
	s_load_b128 s[36:39], s[0:1], 0x70                         // 000000185E4C: F4080900 F8000070
	s_load_b128 s[16:19], s[0:1], 0x98                         // 000000185E54: F4080400 F8000098
	s_cbranch_execnz 1                                         // 000000185E5C: BFA60001 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x64>
	s_mov_b32 s5, 0                                            // 000000185E60: BE850080
	s_clause 0x1                                               // 000000185E64: BF850001
	s_load_b32 s40, s[0:1], 0x80                               // 000000185E68: F4000A00 F8000080
	s_load_b32 s41, s[0:1], 0xa8                               // 000000185E70: F4000A40 F80000A8
	s_and_b32 vcc_lo, exec_lo, s5                              // 000000185E78: 8B6A057E
	s_mov_b32 s42, 0                                           // 000000185E7C: BEAA0080
	s_cbranch_vccnz 18                                         // 000000185E80: BFA40012 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xcc>
	s_cmp_eq_u64 s[12:13], 0                                   // 000000185E84: BF10800C
	s_mov_b32 s21, 0                                           // 000000185E88: BE950080
	s_cbranch_scc1 1115                                        // 000000185E8C: BFA2045B <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x11fc>
	s_lshl_b64 s[6:7], s[20:21], 2                             // 000000185E90: 84868214
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000185E94: BF870009
	s_add_u32 s6, s12, s6                                      // 000000185E98: 8006060C
	s_addc_u32 s7, s13, s7                                     // 000000185E9C: 8207070D
	s_load_b32 s42, s[6:7], null                               // 000000185EA0: F4000A83 F8000000
	s_and_not1_b32 vcc_lo, exec_lo, s21                        // 000000185EA8: 916A157E
	s_cbranch_vccnz 7                                          // 000000185EAC: BFA40007 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xcc>
	s_load_b64 s[6:7], s[0:1], 0x8c                            // 000000185EB0: F4040180 F800008C
	s_waitcnt lgkmcnt(0)                                       // 000000185EB8: BF89FC07
	s_mul_hi_u32 s3, s20, s6                                   // 000000185EBC: 96830614
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000185EC0: BF870499
	s_add_i32 s3, s20, s3                                      // 000000185EC4: 81030314
	s_lshr_b32 s42, s3, s7                                     // 000000185EC8: 852A0703
	s_load_b64 s[6:7], s[0:1], 0x58                            // 000000185ECC: F4040180 F8000058
	s_and_b32 s3, exec_lo, s5                                  // 000000185ED4: 8B03057E
	s_cselect_b32 s33, 0, s20                                  // 000000185ED8: 98211480
	s_cmp_eq_u64 s[12:13], 0                                   // 000000185EDC: BF10800C
	s_mov_b32 s3, s33                                          // 000000185EE0: BE830021
	s_mov_b32 s43, s33                                         // 000000185EE4: BEAB0021
	s_cbranch_scc1 9                                           // 000000185EE8: BFA20009 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x110>
	s_waitcnt lgkmcnt(0)                                       // 000000185EEC: BF89FC07
	s_mul_hi_u32 s3, s33, s37                                  // 000000185EF0: 96832521
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000185EF4: BF870499
	s_add_i32 s3, s33, s3                                      // 000000185EF8: 81030321
	s_lshr_b32 s3, s3, s38                                     // 000000185EFC: 85032603
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000185F00: BF870499
	s_mul_i32 s3, s3, s39                                      // 000000185F04: 96032703
	s_sub_i32 s43, s33, s3                                     // 000000185F08: 81AB0321
	s_mov_b32 s3, s42                                          // 000000185F0C: BE83002A
	s_clause 0x1                                               // 000000185F10: BF850001
	s_load_b64 s[12:13], s[0:1], 0x40                          // 000000185F14: F4040300 F8000040
	s_load_b128 s[20:23], s[0:1], 0xb0                         // 000000185F1C: F4080500 F80000B0
	v_bfe_u32 v13, v0, 10, 10                                  // 000000185F24: D610000D 02291500
	v_dual_mov_b32 v11, 0 :: v_dual_and_b32 v10, 0x3ff, v0     // 000000185F2C: CA240080 0B0A00FF 000003FF
	v_mov_b32_e32 v12, 0                                       // 000000185F38: 7E180280
	s_cmp_lg_u64 s[28:29], 0                                   // 000000185F3C: BF11801C
	s_waitcnt lgkmcnt(0)                                       // 000000185F40: BF89FC07
	s_mov_b32 s37, exec_lo                                     // 000000185F44: BEA5007E
	v_or_b32_e32 v0, v10, v13                                  // 000000185F48: 38001B0A
	s_cselect_b32 s23, -1, 0                                   // 000000185F4C: 981780C1
	s_delay_alu instid0(VALU_DEP_1)                            // 000000185F50: BF870001
	v_cmpx_eq_u32_e32 0, v0                                    // 000000185F54: 7D940080
	s_cbranch_execz 46                                         // 000000185F58: BFA5002E <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x214>
	v_dual_mov_b32 v11, 0 :: v_dual_lshlrev_b32 v0, 2, v10     // 000000185F5C: CA220080 0B001482
	v_mov_b32_e32 v12, 0                                       // 000000185F64: 7E180280
	s_cmp_eq_u64 s[14:15], 0                                   // 000000185F68: BF10800E
	s_mul_i32 s34, s3, s18                                     // 000000185F6C: 96221203
	s_cbranch_scc1 17                                          // 000000185F70: BFA20011 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1b8>
	s_mul_i32 s38, s22, s4                                     // 000000185F74: 96260416
	s_mov_b32 s39, 0                                           // 000000185F78: BEA70080
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 000000185F7C: BF8704D9
	s_lshl_b64 s[44:45], s[38:39], 2                           // 000000185F80: 84AC8226
	s_mov_b32 s35, s39                                         // 000000185F84: BEA30027
	s_add_u32 s3, s14, s44                                     // 000000185F88: 80032C0E
	s_addc_u32 s38, s15, s45                                   // 000000185F8C: 82262D0F
	s_lshl_b64 s[14:15], s[34:35], 2                           // 000000185F90: 848E8222
	s_add_u32 s35, s3, s14                                     // 000000185F94: 80230E03
	s_addc_u32 s38, s38, s15                                   // 000000185F98: 82260F26
	s_ashr_i32 s3, s2, 31                                      // 000000185F9C: 86039F02
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000185FA0: BF870499
	s_lshl_b64 s[14:15], s[2:3], 2                             // 000000185FA4: 848E8202
	s_add_u32 s14, s35, s14                                    // 000000185FA8: 800E0E23
	s_addc_u32 s15, s38, s15                                   // 000000185FAC: 820F0F26
	global_load_b32 v12, v0, s[14:15]                          // 000000185FB0: DC520000 0C0E0000
	s_cmp_lg_u64 s[30:31], 0                                   // 000000185FB8: BF11801E
	s_cselect_b32 s3, -1, 0                                    // 000000185FBC: 980380C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000185FC0: BF870499
	s_and_b32 s3, s3, s23                                      // 000000185FC4: 8B031703
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 000000185FC8: 916A037E
	s_cbranch_vccnz 17                                         // 000000185FCC: BFA40011 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x214>
	s_mul_i32 s14, s22, s4                                     // 000000185FD0: 960E0416
	s_mov_b32 s15, 0                                           // 000000185FD4: BE8F0080
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 000000185FD8: BF8704D9
	s_lshl_b64 s[38:39], s[14:15], 2                           // 000000185FDC: 84A6820E
	s_mov_b32 s35, s15                                         // 000000185FE0: BEA3000F
	s_add_u32 s3, s30, s38                                     // 000000185FE4: 8003261E
	s_addc_u32 s30, s31, s39                                   // 000000185FE8: 821E271F
	s_lshl_b64 s[14:15], s[34:35], 2                           // 000000185FEC: 848E8222
	s_add_u32 s31, s3, s14                                     // 000000185FF0: 801F0E03
	s_addc_u32 s30, s30, s15                                   // 000000185FF4: 821E0F1E
	s_ashr_i32 s3, s2, 31                                      // 000000185FF8: 86039F02
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000185FFC: BF870499
	s_lshl_b64 s[14:15], s[2:3], 2                             // 000000186000: 848E8202
	s_add_u32 s14, s31, s14                                    // 000000186004: 800E0E1F
	s_addc_u32 s15, s30, s15                                   // 000000186008: 820F0F1E
	global_load_b32 v11, v0, s[14:15]                          // 00000018600C: DC520000 0B0E0000
	s_or_b32 exec_lo, exec_lo, s37                             // 000000186014: 8C7E257E
	v_lshl_add_u32 v0, v13, 5, v10                             // 000000186018: D6460000 04290B0D
	v_mov_b32_e32 v17, 0                                       // 000000186020: 7E220280
	v_cndmask_b32_e64 v14, 0, 1, s23                           // 000000186024: D501000E 005D0280
	v_mov_b32_e32 v15, 0                                       // 00000018602C: 7E1E0280
	s_lshr_b32 s30, s36, 8                                     // 000000186030: 851E8824
	v_lshrrev_b32_e32 v16, 3, v0                               // 000000186034: 32200083
	s_mov_b32 s31, exec_lo                                     // 000000186038: BE9F007E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000018603C: BF870001
	v_cmpx_gt_u32_e64 s30, v16                                 // 000000186040: D4CC007E 0002201E
	s_cbranch_execz 842                                        // 000000186048: BFA5034A <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xf74>
	v_lshrrev_b32_e32 v2, 3, v0                                // 00000018604C: 32040083
	s_mul_i32 s14, s43, s17                                    // 000000186050: 960E112B
	s_mul_i32 s17, s21, s4                                     // 000000186054: 96110415
	s_mul_hi_u32 s15, s14, 36                                  // 000000186058: 968FA40E
	s_mul_i32 s14, s14, 36                                     // 00000018605C: 960EA40E
	v_dual_mov_b32 v15, 0 :: v_dual_and_b32 v18, 7, v10        // 000000186060: CA240080 0F121487
	v_mad_u64_u32 v[0:1], null, 0x120, v2, s[14:15]            // 000000186068: D6FE7C00 003A04FF 00000120
	v_dual_mov_b32 v17, 0 :: v_dual_lshlrev_b32 v4, 1, v10     // 000000186074: CA220080 11041481
	s_mul_hi_u32 s3, s19, s4                                   // 00000018607C: 96830413
	s_mul_i32 s40, s40, s2                                     // 000000186080: 96280228
	s_add_i32 s3, s4, s3                                       // 000000186084: 81030304
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000186088: BF870191
	v_and_b32_e32 v5, 14, v4                                   // 00000018608C: 360A088E
	v_mad_u64_u32 v[2:3], null, s17, 36, v[0:1]                // 000000186090: D6FE7C02 04014811
	s_lshr_b32 s3, s3, s41                                     // 000000186098: 85032903
	s_and_b32 s14, exec_lo, s5                                 // 00000018609C: 8B0E057E
	s_mul_i32 s3, s3, s20                                      // 0000001860A0: 96031403
	v_bfe_u32 v19, v4, 2, 2                                    // 0000001860A4: D6100013 02090504
	v_lshlrev_b32_e32 v22, 1, v5                               // 0000001860AC: 302C0A81
	s_cselect_b32 s15, s27, s29                                // 0000001860B0: 980F1D1B
	v_mad_u64_u32 v[0:1], null, v18, 36, v[2:3]                // 0000001860B4: D6FE7C00 04094912
	v_lshlrev_b32_e32 v2, 1, v5                                // 0000001860BC: 30040A81
	s_cselect_b32 s14, s26, s28                                // 0000001860C0: 980E1C1A
	s_cselect_b32 s9, s25, s9                                  // 0000001860C4: 98090919
	s_cselect_b32 s8, s24, s8                                  // 0000001860C8: 98080818
	s_mul_i32 s17, s42, s16                                    // 0000001860CC: 9611102A
	v_and_b32_e32 v20, 4, v2                                   // 0000001860D0: 36280484
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001860D4: BF870093
	v_add_co_u32 v0, vcc_lo, s10, v0                           // 0000001860D8: D7006A00 0002000A
	v_add_co_ci_u32_e64 v1, null, s11, v1, vcc_lo              // 0000001860E0: D5207C01 01AA020B
	v_lshlrev_b32_e32 v21, 1, v2                               // 0000001860E8: 302A0481
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001860EC: BF870093
	v_add_co_u32 v8, vcc_lo, v0, 32                            // 0000001860F0: D7006A08 00014100
	v_add_co_ci_u32_e64 v9, null, 0, v1, vcc_lo                // 0000001860F8: D5207C09 01AA0280
	s_add_i32 s3, s3, s40                                      // 000000186100: 81032803
	s_mov_b32 s16, 0                                           // 000000186104: BE900080
	s_add_i32 s17, s17, s3                                     // 000000186108: 81110311
	s_getpc_b64 s[10:11]                                       // 00000018610C: BE8A4700
	s_add_u32 s10, s10, 0xfff1cdf0                             // 000000186110: 800AFF0A FFF1CDF0
	s_addc_u32 s11, s11, -1                                    // 000000186118: 820BFF0B FFFFFFFF
	s_branch 281                                               // 000000186120: BFA00119 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x788>
	v_lshlrev_b32_e32 v35, 21, v28                             // 000000186124: 30463895
	v_lshlrev_b32_e32 v36, 7, v28                              // 000000186128: 30483887
	v_lshlrev_b32_e32 v38, 17, v28                             // 00000018612C: 304C3891
	v_lshlrev_b32_e32 v37, 3, v28                              // 000000186130: 304A3883
	v_lshrrev_b32_e32 v41, 1, v28                              // 000000186134: 32523881
	v_and_b32_e32 v35, 0x1800000, v35                          // 000000186138: 364646FF 01800000
	v_lshlrev_b32_e32 v42, 13, v28                             // 000000186140: 3054388D
	v_and_b32_e32 v38, 0x1800000, v38                          // 000000186144: 364C4CFF 01800000
	v_lshlrev_b32_e32 v43, 9, v28                              // 00000018614C: 30563889
	v_and_b32_e32 v41, 0x180, v41                              // 000000186150: 365252FF 00000180
	v_and_or_b32 v35, 0x180, v36, v35                          // 000000186158: D6570023 048E48FF 00000180
	v_lshrrev_b32_e32 v36, 5, v28                              // 000000186164: 32483885
	v_and_or_b32 v37, 0x180, v37, v38                          // 000000186168: D6570025 049A4AFF 00000180
	v_lshrrev_b32_e32 v45, 9, v28                              // 000000186174: 325A3889
	v_and_or_b32 v41, 0x1800000, v42, v41                      // 000000186178: D6570029 04A654FF 01800000
	v_and_b32_e32 v38, 0x1000100, v35                          // 000000186184: 364C46FF 01000100
	v_and_b32_e32 v36, 0x180, v36                              // 00000018618C: 364848FF 00000180
	v_and_b32_e32 v42, 0x1000100, v37                          // 000000186194: 36544AFF 01000100
	v_lshrrev_b32_e32 v47, 13, v28                             // 00000018619C: 325E388D
	s_waitcnt vmcnt(7)                                         // 0000001861A0: BF891FF7
	v_and_b32_e32 v39, 0x80808080, v34                         // 0000001861A4: 364E44FF 80808080
	v_add_nc_u32_e32 v38, 0x7f7f7f7f, v38                      // 0000001861AC: 4A4C4CFF 7F7F7F7F
	v_and_or_b32 v36, 0x1800000, v43, v36                      // 0000001861B4: D6570024 049256FF 01800000
	v_add_nc_u32_e32 v42, 0x7f7f7f7f, v42                      // 0000001861C0: 4A5454FF 7F7F7F7F
	v_lshlrev_b32_e32 v46, 5, v28                              // 0000001861C8: 305C3885
	v_and_b32_e32 v48, 0x1000100, v41                          // 0000001861CC: 366052FF 01000100
	v_or_b32_e32 v35, v38, v35                                 // 0000001861D4: 38464726
	v_and_b32_e32 v43, 0x180, v45                              // 0000001861D8: 36565AFF 00000180
	v_or_b32_e32 v37, v42, v37                                 // 0000001861E0: 384A4B2A
	v_and_b32_e32 v45, 0x180, v47                              // 0000001861E4: 365A5EFF 00000180
	v_and_b32_e32 v47, 0x1000100, v36                          // 0000001861EC: 365E48FF 01000100
	v_lshrrev_b32_e32 v35, 7, v35                              // 0000001861F4: 32464687
	s_waitcnt vmcnt(6)                                         // 0000001861F8: BF891BF7
	v_and_b32_e32 v40, 0x80808080, v33                         // 0000001861FC: 365042FF 80808080
	v_lshrrev_b32_e32 v37, 7, v37                              // 000000186204: 324A4A87
	v_add_nc_u32_e32 v48, 0x7f7f7f7f, v48                      // 000000186208: 4A6060FF 7F7F7F7F
	v_and_or_b32 v43, 0x1800000, v46, v43                      // 000000186210: D657002B 04AE5CFF 01800000
	v_and_b32_e32 v35, 0x1010101, v35                          // 00000018621C: 364646FF 01010101
	v_add_nc_u32_e32 v46, 0x7f7f7f7f, v47                      // 000000186224: 4A5C5EFF 7F7F7F7F
	v_and_b32_e32 v37, 0x1010101, v37                          // 00000018622C: 364A4AFF 01010101
	v_lshlrev_b32_e32 v38, 1, v28                              // 000000186234: 304C3881
	v_or_b32_e32 v41, v48, v41                                 // 000000186238: 38525330
	v_mul_lo_u32 v35, 0xff, v35                                // 00000018623C: D72C0023 000246FF 000000FF
	v_or_b32_e32 v36, v46, v36                                 // 000000186248: 3848492E
	v_mul_lo_u32 v37, 0xff, v37                                // 00000018624C: D72C0025 00024AFF 000000FF
	v_lshrrev_b32_e32 v42, 3, v28                              // 000000186258: 32543883
	v_lshrrev_b32_e32 v41, 7, v41                              // 00000018625C: 32525287
	v_and_or_b32 v38, 0x1800000, v38, v45                      // 000000186260: D6570026 04B64CFF 01800000
	v_lshrrev_b32_e32 v49, 17, v28                             // 00000018626C: 32623891
	v_lshrrev_b32_e32 v48, 7, v28                              // 000000186270: 32603887
	v_xor_b32_e32 v34, v35, v34                                // 000000186274: 3A444523
	v_and_b32_e32 v35, 0x7f7f7f7f, v35                         // 000000186278: 364646FF 7F7F7F7F
	v_xor_b32_e32 v33, v37, v33                                // 000000186280: 3A424325
	v_and_b32_e32 v37, 0x7f7f7f7f, v37                         // 000000186284: 364A4AFF 7F7F7F7F
	v_and_b32_e32 v41, 0x1010101, v41                          // 00000018628C: 365252FF 01010101
	v_or_b32_e32 v34, 0x80808080, v34                          // 000000186294: 384444FF 80808080
	v_and_b32_e32 v42, 0x1800000, v42                          // 00000018629C: 365454FF 01800000
	v_or_b32_e32 v33, 0x80808080, v33                          // 0000001862A4: 384242FF 80808080
	v_lshrrev_b32_e32 v28, 21, v28                             // 0000001862AC: 32383895
	v_mul_lo_u32 v41, 0xff, v41                                // 0000001862B0: D72C0029 000252FF 000000FF
	v_sub_nc_u32_e32 v34, v34, v35                             // 0000001862BC: 4C444722
	v_lshrrev_b32_e32 v35, 7, v36                              // 0000001862C0: 32464887
	v_and_b32_e32 v36, 0x1000100, v43                          // 0000001862C4: 364856FF 01000100
	v_sub_nc_u32_e32 v33, v33, v37                             // 0000001862CC: 4C424B21
	s_waitcnt vmcnt(5)                                         // 0000001862D0: BF8917F7
	v_and_b32_e32 v44, 0x80808080, v32                         // 0000001862D4: 365840FF 80808080
	v_xor3_b32 v34, v39, v34, 0x80808080                       // 0000001862DC: D6400022 03FE4527 80808080
	v_and_b32_e32 v35, 0x1010101, v35                          // 0000001862E8: 364646FF 01010101
	v_xor_b32_e32 v32, v41, v32                                // 0000001862F0: 3A404129
	v_xor3_b32 v33, v40, v33, 0x80808080                       // 0000001862F4: D6400021 03FE4328 80808080
	v_and_b32_e32 v37, 0x7f7f7f7f, v41                         // 000000186300: 364A52FF 7F7F7F7F
	v_dot4_i32_iu8 v5, v34, v5, 0 neg_lo:[1,1,0]               // 000000186308: CC164005 7A020B22
	v_add_nc_u32_e32 v34, 0x7f7f7f7f, v36                      // 000000186310: 4A4448FF 7F7F7F7F
	v_and_b32_e32 v36, 0x1000100, v38                          // 000000186318: 36484CFF 01000100
	v_mul_lo_u32 v35, 0xff, v35                                // 000000186320: D72C0023 000246FF 000000FF
	v_or_b32_e32 v32, 0x80808080, v32                          // 00000018632C: 384040FF 80808080
	v_dot4_i32_iu8 v5, v33, v6, v5 neg_lo:[1,1,0]              // 000000186334: CC164005 7C160D21
	v_or_b32_e32 v6, v34, v43                                  // 00000018633C: 380C5722
	v_add_nc_u32_e32 v33, 0x7f7f7f7f, v36                      // 000000186340: 4A4248FF 7F7F7F7F
	v_and_b32_e32 v34, 0x1800000, v48                          // 000000186348: 364460FF 01800000
	v_and_or_b32 v36, 0x180, v49, v42                          // 000000186350: D6570024 04AA62FF 00000180
	v_sub_nc_u32_e32 v32, v32, v37                             // 00000018635C: 4C404B20
	v_lshrrev_b32_e32 v6, 7, v6                                // 000000186360: 320C0C87
	v_or_b32_e32 v33, v33, v38                                 // 000000186364: 38424D21
	v_and_or_b32 v28, 0x180, v28, v34                          // 000000186368: D657001C 048A38FF 00000180
	v_and_b32_e32 v34, 0x1000100, v36                          // 000000186374: 364448FF 01000100
	s_waitcnt vmcnt(4)                                         // 00000018637C: BF8913F7
	v_xor_b32_e32 v37, v35, v31                                // 000000186380: 3A4A3F23
	v_and_b32_e32 v6, 0x1010101, v6                            // 000000186384: 360C0CFF 01010101
	v_lshrrev_b32_e32 v33, 7, v33                              // 00000018638C: 32424287
	v_and_b32_e32 v38, 0x1000100, v28                          // 000000186390: 364C38FF 01000100
	v_add_nc_u32_e32 v34, 0x7f7f7f7f, v34                      // 000000186398: 4A4444FF 7F7F7F7F
	v_or_b32_e32 v37, 0x80808080, v37                          // 0000001863A0: 384A4AFF 80808080
	v_mul_lo_u32 v6, 0xff, v6                                  // 0000001863A8: D72C0006 00020CFF 000000FF
	v_and_b32_e32 v33, 0x1010101, v33                          // 0000001863B4: 364242FF 01010101
	v_add_nc_u32_e32 v38, 0x7f7f7f7f, v38                      // 0000001863BC: 4A4C4CFF 7F7F7F7F
	v_or_b32_e32 v34, v34, v36                                 // 0000001863C4: 38444922
	v_and_b32_e32 v35, 0x7f7f7f7f, v35                         // 0000001863C8: 364646FF 7F7F7F7F
	v_and_b32_e32 v31, 0x80808080, v31                         // 0000001863D0: 363E3EFF 80808080
	v_mul_lo_u32 v33, 0xff, v33                                // 0000001863D8: D72C0021 000242FF 000000FF
	v_or_b32_e32 v28, v38, v28                                 // 0000001863E4: 38383926
	v_lshrrev_b32_e32 v34, 7, v34                              // 0000001863E8: 32444487
	v_sub_nc_u32_e32 v35, v37, v35                             // 0000001863EC: 4C464725
	s_waitcnt vmcnt(3)                                         // 0000001863F0: BF890FF7
	v_xor_b32_e32 v36, v6, v30                                 // 0000001863F4: 3A483D06
	v_xor3_b32 v32, v44, v32, 0x80808080                       // 0000001863F8: D6400020 03FE412C 80808080
	v_lshrrev_b32_e32 v28, 7, v28                              // 000000186404: 32383887
	v_and_b32_e32 v34, 0x1010101, v34                          // 000000186408: 364444FF 01010101
	v_xor3_b32 v31, v31, v35, 0x80808080                       // 000000186410: D640001F 03FE471F 80808080
	v_or_b32_e32 v35, 0x80808080, v36                          // 00000018641C: 384648FF 80808080
	s_waitcnt vmcnt(2)                                         // 000000186424: BF890BF7
	v_xor_b32_e32 v36, v33, v29                                // 000000186428: 3A483B21
	v_and_b32_e32 v28, 0x1010101, v28                          // 00000018642C: 363838FF 01010101
	v_mul_lo_u32 v34, 0xff, v34                                // 000000186434: D72C0022 000244FF 000000FF
	v_and_b32_e32 v6, 0x7f7f7f7f, v6                           // 000000186440: 360C0CFF 7F7F7F7F
	v_dot4_i32_iu8 v5, v32, v7, v5 neg_lo:[1,1,0]              // 000000186448: CC164005 7C160F20
	v_or_b32_e32 v7, 0x80808080, v36                           // 000000186450: 380E48FF 80808080
	v_mul_lo_u32 v28, 0xff, v28                                // 000000186458: D72C001C 000238FF 000000FF
	v_and_b32_e32 v32, 0x7f7f7f7f, v33                         // 000000186464: 364042FF 7F7F7F7F
	v_sub_nc_u32_e32 v6, v35, v6                               // 00000018646C: 4C0C0D23
	v_and_b32_e32 v30, 0x80808080, v30                         // 000000186470: 363C3CFF 80808080
	v_dot4_i32_iu8 v0, v31, v0, v5 neg_lo:[1,1,0]              // 000000186478: CC164000 7C16011F
	s_waitcnt vmcnt(1)                                         // 000000186480: BF8907F7
	v_xor_b32_e32 v5, v27, v34                                 // 000000186484: 3A0A451B
	v_sub_nc_u32_e32 v7, v7, v32                               // 000000186488: 4C0E4107
	v_and_b32_e32 v29, 0x80808080, v29                         // 00000018648C: 363A3AFF 80808080
	v_xor3_b32 v6, v30, v6, 0x80808080                         // 000000186494: D6400006 03FE0D1E 80808080
	s_waitcnt vmcnt(0)                                         // 0000001864A0: BF8903F7
	v_xor_b32_e32 v30, v26, v28                                // 0000001864A4: 3A3C391A
	v_or_b32_e32 v5, 0x80808080, v5                            // 0000001864A8: 380A0AFF 80808080
	v_and_b32_e32 v31, 0x7f7f7f7f, v34                         // 0000001864B0: 363E44FF 7F7F7F7F
	v_xor3_b32 v7, v29, v7, 0x80808080                         // 0000001864B8: D6400007 03FE0F1D 80808080
	v_dot4_i32_iu8 v0, v6, v1, v0 neg_lo:[1,1,0]               // 0000001864C4: CC164000 7C020306
	v_or_b32_e32 v1, 0x80808080, v30                           // 0000001864CC: 38023CFF 80808080
	v_and_b32_e32 v6, 0x7f7f7f7f, v28                          // 0000001864D4: 360C38FF 7F7F7F7F
	v_sub_nc_u32_e32 v5, v5, v31                               // 0000001864DC: 4C0A3F05
	v_and_b32_e32 v27, 0x80808080, v27                         // 0000001864E0: 363636FF 80808080
	v_and_b32_e32 v24, 0xff, v24                               // 0000001864E8: 363030FF 000000FF
	v_dot4_i32_iu8 v0, v7, v2, v0 neg_lo:[1,1,0]               // 0000001864F0: CC164000 7C020507
	v_sub_nc_u32_e32 v1, v1, v6                                // 0000001864F8: 4C020D01
	v_and_b32_e32 v2, 0x80808080, v26                          // 0000001864FC: 360434FF 80808080
	v_xor3_b32 v5, v27, v5, 0x80808080                         // 000000186504: D6400005 03FE0B1B 80808080
	v_lshrrev_b32_e32 v6, v20, v24                             // 000000186510: 320C3114
	v_add_nc_u32_e32 v16, 4, v16                               // 000000186514: 4A202084
	v_add_co_u32 v8, s3, 0x480, v8                             // 000000186518: D7000308 000210FF 00000480
	v_xor3_b32 v1, v2, v1, 0x80808080                          // 000000186524: D6400001 03FE0302 80808080
	v_dot4_i32_iu8 v0, v5, v3, v0 neg_lo:[1,1,0]               // 000000186530: CC164000 7C020705
	v_lshlrev_b32_e32 v2, 1, v6                                // 000000186538: 30040C81
	v_cmp_le_u32_e32 vcc_lo, s30, v16                          // 00000018653C: 7C96201E
	v_add_co_ci_u32_e64 v9, null, 0, v9, s3                    // 000000186540: D5207C09 000E1280
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 000000186548: BF870214
	v_dot4_i32_iu8 v0, v1, v23, v0 neg_lo:[1,1,0]              // 00000018654C: CC164000 7C022F01
	v_and_or_b32 v1, v2, 30, 1                                 // 000000186554: D6570001 02053D02
	s_or_b32 s16, vcc_lo, s16                                  // 00000018655C: 8C10106A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000186560: BF8700A1
	v_mul_lo_u32 v0, v1, v0                                    // 000000186564: D72C0000 00020101
	v_cvt_f32_f16_e32 v1, v4.h                                 // 00000018656C: 7E021784
	v_mul_f32_e32 v1, v1, v25                                  // 000000186570: 10023301
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000186574: BF870093
	v_cvt_f32_i32_e32 v0, v0                                   // 000000186578: 7E000B00
	v_fmac_f32_e32 v17, v1, v0                                 // 00000018657C: 56220101
	s_and_not1_b32 exec_lo, exec_lo, s16                       // 000000186580: 917E107E
	s_cbranch_execz 506                                        // 000000186584: BFA501FA <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xf70>
	v_add_nc_u32_e32 v35, s17, v16                             // 000000186588: 4A462011
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000018658C: BF870091
	v_mad_i64_i32 v[25:26], null, 0x6e, v35, s[8:9]            // 000000186590: D6FF7C19 002246FF 0000006E
	v_add_co_u32 v0, vcc_lo, v25, v21                          // 00000018659C: D7006A00 00022B19
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 0000001865A4: BF8700A1
	v_add_co_ci_u32_e64 v1, null, 0, v26, vcc_lo               // 0000001865A8: D5207C01 01AA3480
	v_add_co_u32 v2, vcc_lo, v25, v18                          // 0000001865B0: D7006A02 00022519
	v_add_co_ci_u32_e64 v3, null, 0, v26, vcc_lo               // 0000001865B8: D5207C03 01AA3480
	s_clause 0x1                                               // 0000001865C0: BF850001
	global_load_b64 v[29:30], v[0:1], off offset:2             // 0000001865C4: DC560002 1D7C0000
	global_load_u8 v33, v[2:3], off offset:66                  // 0000001865CC: DC420042 217C0002
	v_add_co_u32 v27, vcc_lo, v25, v22                         // 0000001865D4: D7006A1B 00022D19
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 0000001865DC: BF8700A1
	v_add_co_ci_u32_e64 v28, null, 0, v26, vcc_lo              // 0000001865E0: D5207C1C 01AA3480
	v_add_co_u32 v31, vcc_lo, v25, v19                         // 0000001865E8: D7006A1F 00022719
	v_add_co_ci_u32_e64 v32, null, 0, v26, vcc_lo              // 0000001865F0: D5207C20 01AA3480
	s_clause 0x2                                               // 0000001865F8: BF850002
	global_load_b128 v[4:7], v[8:9], off offset:-32            // 0000001865FC: DC5E1FE0 047C0008
	global_load_b128 v[0:3], v[8:9], off offset:-16            // 000000186604: DC5E1FF0 007C0008
	global_load_b32 v23, v[8:9], off                           // 00000018660C: DC520000 177C0008
	s_clause 0x2                                               // 000000186614: BF850002
	global_load_b32 v28, v[27:28], off offset:74               // 000000186618: DC52004A 1C7C001B
	global_load_d16_u8 v24, v[31:32], off offset:106           // 000000186620: DC7A006A 187C001F
	global_load_d16_hi_b16 v4, v[25:26], off                   // 000000186628: DC8E0000 047C0019
	s_and_not1_b32 vcc_lo, exec_lo, s23                        // 000000186630: 916A177E
	s_waitcnt vmcnt(7)                                         // 000000186634: BF891FF7
	v_and_b32_e32 v25, 0xff, v29                               // 000000186638: 36323AFF 000000FF
	s_waitcnt vmcnt(6)                                         // 000000186640: BF891BF7
	v_lshlrev_b32_e32 v26, 8, v33                              // 000000186644: 30344288
	v_bfe_u32 v27, v29, 8, 8                                   // 000000186648: D610001B 0221111D
	v_lshlrev_b32_e32 v31, 7, v33                              // 000000186650: 303E4287
	v_bfe_u32 v32, v29, 16, 8                                  // 000000186654: D6100020 0221211D
	v_lshlrev_b32_e32 v34, 6, v33                              // 00000018665C: 30444286
	v_lshrrev_b32_e32 v29, 24, v29                             // 000000186660: 323A3A98
	v_lshlrev_b32_e32 v36, 5, v33                              // 000000186664: 30484285
	v_and_b32_e32 v37, 0xff, v30                               // 000000186668: 364A3CFF 000000FF
	v_lshlrev_b32_e32 v38, 4, v33                              // 000000186670: 304C4284
	v_bfe_u32 v39, v30, 8, 8                                   // 000000186674: D6100027 0221111E
	v_lshlrev_b32_e32 v40, 3, v33                              // 00000018667C: 30504283
	v_bfe_u32 v41, v30, 16, 8                                  // 000000186680: D6100029 0221211E
	v_lshlrev_b32_e32 v42, 2, v33                              // 000000186688: 30544282
	v_lshrrev_b32_e32 v30, 24, v30                             // 00000018668C: 323C3C98
	v_lshlrev_b32_e32 v33, 1, v33                              // 000000186690: 30424281
	v_and_or_b32 v25, 0x100, v26, v25                          // 000000186694: D6570019 046634FF 00000100
	v_and_or_b32 v26, 0x100, v31, v27                          // 0000001866A0: D657001A 046E3EFF 00000100
	v_and_or_b32 v27, 0x100, v34, v32                          // 0000001866AC: D657001B 048244FF 00000100
	v_and_or_b32 v29, 0x100, v36, v29                          // 0000001866B8: D657001D 047648FF 00000100
	v_and_or_b32 v31, 0x100, v38, v37                          // 0000001866C4: D657001F 04964CFF 00000100
	v_and_or_b32 v32, 0x100, v40, v39                          // 0000001866D0: D6570020 049E50FF 00000100
	v_and_or_b32 v34, 0x100, v42, v41                          // 0000001866DC: D6570022 04A654FF 00000100
	v_and_or_b32 v30, 0x100, v33, v30                          // 0000001866E8: D657001E 047A42FF 00000100
	v_lshlrev_b32_e32 v25, 2, v25                              // 0000001866F4: 30323282
	v_lshlrev_b32_e32 v26, 2, v26                              // 0000001866F8: 30343482
	v_lshlrev_b32_e32 v27, 2, v27                              // 0000001866FC: 30363682
	v_lshlrev_b32_e32 v29, 2, v29                              // 000000186700: 303A3A82
	v_lshlrev_b32_e32 v36, 2, v31                              // 000000186704: 30483E82
	v_lshlrev_b32_e32 v37, 2, v32                              // 000000186708: 304A4082
	v_lshlrev_b32_e32 v38, 2, v34                              // 00000018670C: 304C4482
	v_lshlrev_b32_e32 v39, 2, v30                              // 000000186710: 304E3C82
	s_clause 0x7                                               // 000000186714: BF850007
	global_load_b32 v34, v25, s[10:11]                         // 000000186718: DC520000 220A0019
	global_load_b32 v33, v26, s[10:11]                         // 000000186720: DC520000 210A001A
	global_load_b32 v32, v27, s[10:11]                         // 000000186728: DC520000 200A001B
	global_load_b32 v31, v29, s[10:11]                         // 000000186730: DC520000 1F0A001D
	global_load_b32 v30, v36, s[10:11]                         // 000000186738: DC520000 1E0A0024
	global_load_b32 v29, v37, s[10:11]                         // 000000186740: DC520000 1D0A0025
	global_load_b32 v27, v38, s[10:11]                         // 000000186748: DC520000 1B0A0026
	global_load_b32 v26, v39, s[10:11]                         // 000000186750: DC520000 1A0A0027
	s_waitcnt vmcnt(8)                                         // 000000186758: BF8923F7
	v_cvt_f32_f16_e32 v25, v4.l                                // 00000018675C: 7E321704
	s_cbranch_vccnz 65136                                      // 000000186760: BFA4FE70 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x324>
	v_mad_i64_i32 v[36:37], null, 0x6e, v35, s[14:15]          // 000000186764: D6FF7C24 003A46FF 0000006E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000186770: BF870091
	v_add_co_u32 v38, vcc_lo, v36, v21                         // 000000186774: D7006A26 00022B24
	v_add_co_ci_u32_e64 v39, null, 0, v37, vcc_lo              // 00000018677C: D5207C27 01AA4A80
	v_add_co_u32 v40, vcc_lo, v36, v18                         // 000000186784: D7006A28 00022524
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_1)// 00000018678C: BF8700D1
	v_add_co_ci_u32_e64 v41, null, 0, v37, vcc_lo              // 000000186790: D5207C29 01AA4A80
	s_clause 0x1                                               // 000000186798: BF850001
	global_load_b64 v[38:39], v[38:39], off offset:2           // 00000018679C: DC560002 267C0026
	global_load_u8 v35, v[40:41], off offset:66                // 0000001867A4: DC420042 237C0028
	v_add_co_u32 v40, vcc_lo, v36, v22                         // 0000001867AC: D7006A28 00022D24
	v_add_co_ci_u32_e64 v41, null, 0, v37, vcc_lo              // 0000001867B4: D5207C29 01AA4A80
	global_load_b32 v40, v[40:41], off offset:74               // 0000001867BC: DC52004A 287C0028
	s_waitcnt vmcnt(2)                                         // 0000001867C4: BF890BF7
	v_and_b32_e32 v41, 0xff, v38                               // 0000001867C8: 36524CFF 000000FF
	s_waitcnt vmcnt(1)                                         // 0000001867D0: BF8907F7
	v_lshlrev_b32_e32 v42, 8, v35                              // 0000001867D4: 30544688
	v_bfe_u32 v43, v38, 8, 8                                   // 0000001867D8: D610002B 02211126
	v_lshlrev_b32_e32 v44, 7, v35                              // 0000001867E0: 30584687
	v_bfe_u32 v45, v38, 16, 8                                  // 0000001867E4: D610002D 02212126
	v_lshlrev_b32_e32 v46, 6, v35                              // 0000001867EC: 305C4686
	v_and_or_b32 v41, 0x100, v42, v41                          // 0000001867F0: D6570029 04A654FF 00000100
	v_lshrrev_b32_e32 v38, 24, v38                             // 0000001867FC: 324C4C98
	v_and_or_b32 v43, 0x100, v44, v43                          // 000000186800: D657002B 04AE58FF 00000100
	v_lshlrev_b32_e32 v47, 5, v35                              // 00000018680C: 305E4685
	v_and_or_b32 v45, 0x100, v46, v45                          // 000000186810: D657002D 04B65CFF 00000100
	v_lshlrev_b32_e32 v41, 2, v41                              // 00000018681C: 30525282
	v_and_b32_e32 v48, 0xff, v39                               // 000000186820: 36604EFF 000000FF
	v_lshlrev_b32_e32 v49, 4, v35                              // 000000186828: 30624684
	v_bfe_u32 v42, v39, 8, 8                                   // 00000018682C: D610002A 02211127
	v_lshlrev_b32_e32 v44, 3, v35                              // 000000186834: 30584683
	global_load_b32 v41, v41, s[10:11]                         // 000000186838: DC520000 290A0029
	v_lshlrev_b32_e32 v43, 2, v43                              // 000000186840: 30565682
	v_lshlrev_b32_e32 v45, 2, v45                              // 000000186844: 305A5A82
	v_and_or_b32 v38, 0x100, v47, v38                          // 000000186848: D6570026 049A5EFF 00000100
	v_and_or_b32 v46, 0x100, v49, v48                          // 000000186854: D657002E 04C262FF 00000100
	s_clause 0x1                                               // 000000186860: BF850001
	global_load_b32 v43, v43, s[10:11]                         // 000000186864: DC520000 2B0A002B
	global_load_b32 v45, v45, s[10:11]                         // 00000018686C: DC520000 2D0A002D
	v_and_or_b32 v42, 0x100, v44, v42                          // 000000186874: D657002A 04AA58FF 00000100
	v_lshlrev_b32_e32 v38, 2, v38                              // 000000186880: 304C4C82
	v_lshlrev_b32_e32 v44, 2, v46                              // 000000186884: 30585C82
	v_lshlrev_b32_e32 v47, 2, v35                              // 000000186888: 305E4682
	v_lshlrev_b32_e32 v35, 1, v35                              // 00000018688C: 30464681
	v_lshlrev_b32_e32 v42, 2, v42                              // 000000186890: 30545482
	s_clause 0x1                                               // 000000186894: BF850001
	global_load_b32 v46, v38, s[10:11]                         // 000000186898: DC520000 2E0A0026
	global_load_b32 v44, v44, s[10:11]                         // 0000001868A0: DC520000 2C0A002C
	s_waitcnt vmcnt(5)                                         // 0000001868A8: BF8917F7
	v_lshlrev_b32_e32 v48, 17, v40                             // 0000001868AC: 30605091
	v_lshrrev_b32_e32 v51, 5, v40                              // 0000001868B0: 32665085
	global_load_b32 v42, v42, s[10:11]                         // 0000001868B4: DC520000 2A0A002A
	v_bfe_u32 v38, v39, 16, 8                                  // 0000001868BC: D6100026 02212127
	v_lshrrev_b32_e32 v39, 24, v39                             // 0000001868C4: 324E4E98
	v_lshrrev_b32_e32 v49, 1, v40                              // 0000001868C8: 32625081
	v_lshlrev_b32_e32 v52, 9, v40                              // 0000001868CC: 30685089
	v_lshrrev_b32_e32 v53, 9, v40                              // 0000001868D0: 326A5089
	v_and_or_b32 v38, 0x100, v47, v38                          // 0000001868D4: D6570026 049A5EFF 00000100
	v_and_or_b32 v35, 0x100, v35, v39                          // 0000001868E0: D6570023 049E46FF 00000100
	v_and_b32_e32 v48, 0x1800000, v48                          // 0000001868EC: 366060FF 01800000
	v_and_b32_e32 v51, 0x180, v51                              // 0000001868F4: 366666FF 00000180
	v_lshlrev_b32_e32 v50, 13, v40                             // 0000001868FC: 3064508D
	v_lshlrev_b32_e32 v38, 2, v38                              // 000000186900: 304C4C82
	v_lshlrev_b32_e32 v35, 2, v35                              // 000000186904: 30464682
	s_clause 0x1                                               // 000000186908: BF850001
	global_load_b32 v47, v38, s[10:11]                         // 00000018690C: DC520000 2F0A0026
	global_load_b32 v35, v35, s[10:11]                         // 000000186914: DC520000 230A0023
	v_add_co_u32 v38, vcc_lo, v36, v19                         // 00000018691C: D7006A26 00022724
	s_delay_alu instid0(VALU_DEP_1)                            // 000000186924: BF870001
	v_add_co_ci_u32_e64 v39, null, 0, v37, vcc_lo              // 000000186928: D5207C27 01AA4A80
	s_clause 0x1                                               // 000000186930: BF850001
	global_load_u8 v38, v[38:39], off offset:106               // 000000186934: DC42006A 267C0026
	global_load_d16_b16 v4, v[36:37], off                      // 00000018693C: DC820000 047C0024
	v_lshlrev_b32_e32 v37, 21, v40                             // 000000186944: 304A5095
	v_lshlrev_b32_e32 v36, 7, v40                              // 000000186948: 30485087
	v_lshlrev_b32_e32 v39, 3, v40                              // 00000018694C: 304E5083
	v_lshlrev_b32_e32 v54, 5, v40                              // 000000186950: 306C5085
	v_and_b32_e32 v49, 0x180, v49                              // 000000186954: 366262FF 00000180
	v_and_b32_e32 v37, 0x1800000, v37                          // 00000018695C: 364A4AFF 01800000
	v_and_b32_e32 v53, 0x180, v53                              // 000000186964: 366A6AFF 00000180
	v_lshrrev_b32_e32 v55, 13, v40                             // 00000018696C: 326E508D
	v_lshlrev_b32_e32 v56, 1, v40                              // 000000186970: 30705081
	v_lshrrev_b32_e32 v58, 3, v40                              // 000000186974: 32745083
	v_and_or_b32 v36, 0x180, v36, v37                          // 000000186978: D6570024 049648FF 00000180
	v_and_or_b32 v37, 0x180, v39, v48                          // 000000186984: D6570025 04C24EFF 00000180
	v_and_or_b32 v48, 0x1800000, v52, v51                      // 000000186990: D6570030 04CE68FF 01800000
	v_and_or_b32 v39, 0x1800000, v50, v49                      // 00000018699C: D6570027 04C664FF 01800000
	v_and_or_b32 v49, 0x1800000, v54, v53                      // 0000001869A8: D6570031 04D66CFF 01800000
	v_and_b32_e32 v52, 0x1000100, v36                          // 0000001869B4: 366848FF 01000100
	v_and_b32_e32 v53, 0x1000100, v37                          // 0000001869BC: 366A4AFF 01000100
	v_and_b32_e32 v55, 0x180, v55                              // 0000001869C4: 366E6EFF 00000180
	v_and_b32_e32 v54, 0x1000100, v39                          // 0000001869CC: 366C4EFF 01000100
	v_lshrrev_b32_e32 v57, 17, v40                             // 0000001869D4: 32725091
	v_add_nc_u32_e32 v52, 0x7f7f7f7f, v52                      // 0000001869D8: 4A6868FF 7F7F7F7F
	v_add_nc_u32_e32 v53, 0x7f7f7f7f, v53                      // 0000001869E0: 4A6A6AFF 7F7F7F7F
	v_and_or_b32 v50, 0x1800000, v56, v55                      // 0000001869E8: D6570032 04DE70FF 01800000
	v_and_b32_e32 v55, 0x1000100, v48                          // 0000001869F4: 366E60FF 01000100
	v_add_nc_u32_e32 v54, 0x7f7f7f7f, v54                      // 0000001869FC: 4A6C6CFF 7F7F7F7F
	v_or_b32_e32 v36, v52, v36                                 // 000000186A04: 38484934
	v_or_b32_e32 v37, v53, v37                                 // 000000186A08: 384A4B35
	v_lshrrev_b32_e32 v59, 21, v40                             // 000000186A0C: 32765095
	v_lshrrev_b32_e32 v40, 7, v40                              // 000000186A10: 32505087
	v_and_b32_e32 v58, 0x1800000, v58                          // 000000186A14: 367474FF 01800000
	v_lshrrev_b32_e32 v36, 7, v36                              // 000000186A1C: 32484887
	v_and_b32_e32 v56, 0x1000100, v49                          // 000000186A20: 367062FF 01000100
	v_add_nc_u32_e32 v55, 0x7f7f7f7f, v55                      // 000000186A28: 4A6E6EFF 7F7F7F7F
	v_or_b32_e32 v39, v54, v39                                 // 000000186A30: 384E4F36
	v_lshrrev_b32_e32 v37, 7, v37                              // 000000186A34: 324A4A87
	v_and_b32_e32 v36, 0x1010101, v36                          // 000000186A38: 364848FF 01010101
	v_and_b32_e32 v40, 0x1800000, v40                          // 000000186A40: 365050FF 01800000
	v_and_or_b32 v51, 0x180, v57, v58                          // 000000186A48: D6570033 04EA72FF 00000180
	v_and_b32_e32 v57, 0x1000100, v50                          // 000000186A54: 367264FF 01000100
	v_add_nc_u32_e32 v56, 0x7f7f7f7f, v56                      // 000000186A5C: 4A7070FF 7F7F7F7F
	v_or_b32_e32 v48, v55, v48                                 // 000000186A64: 38606137
	v_lshrrev_b32_e32 v39, 7, v39                              // 000000186A68: 324E4E87
	v_and_b32_e32 v37, 0x1010101, v37                          // 000000186A6C: 364A4AFF 01010101
	v_mul_lo_u32 v36, 0xff, v36                                // 000000186A74: D72C0024 000248FF 000000FF
	v_and_or_b32 v40, 0x180, v59, v40                          // 000000186A80: D6570028 04A276FF 00000180
	v_and_b32_e32 v58, 0x1000100, v51                          // 000000186A8C: 367466FF 01000100
	v_add_nc_u32_e32 v57, 0x7f7f7f7f, v57                      // 000000186A94: 4A7272FF 7F7F7F7F
	v_or_b32_e32 v49, v56, v49                                 // 000000186A9C: 38626338
	v_lshrrev_b32_e32 v48, 7, v48                              // 000000186AA0: 32606087
	v_and_b32_e32 v39, 0x1010101, v39                          // 000000186AA4: 364E4EFF 01010101
	v_mul_lo_u32 v37, 0xff, v37                                // 000000186AAC: D72C0025 00024AFF 000000FF
	v_and_b32_e32 v52, 0x7f7f7f7f, v36                         // 000000186AB8: 366848FF 7F7F7F7F
	v_and_b32_e32 v59, 0x1000100, v40                          // 000000186AC0: 367650FF 01000100
	v_add_nc_u32_e32 v58, 0x7f7f7f7f, v58                      // 000000186AC8: 4A7474FF 7F7F7F7F
	v_or_b32_e32 v50, v57, v50                                 // 000000186AD0: 38646539
	v_lshrrev_b32_e32 v49, 7, v49                              // 000000186AD4: 32626287
	v_and_b32_e32 v48, 0x1010101, v48                          // 000000186AD8: 366060FF 01010101
	v_mul_lo_u32 v39, 0xff, v39                                // 000000186AE0: D72C0027 00024EFF 000000FF
	v_and_b32_e32 v53, 0x7f7f7f7f, v37                         // 000000186AEC: 366A4AFF 7F7F7F7F
	v_add_nc_u32_e32 v59, 0x7f7f7f7f, v59                      // 000000186AF4: 4A7676FF 7F7F7F7F
	v_or_b32_e32 v51, v58, v51                                 // 000000186AFC: 3866673A
	v_lshrrev_b32_e32 v50, 7, v50                              // 000000186B00: 32646487
	v_and_b32_e32 v49, 0x1010101, v49                          // 000000186B04: 366262FF 01010101
	v_mul_lo_u32 v48, 0xff, v48                                // 000000186B0C: D72C0030 000260FF 000000FF
	v_or_b32_e32 v40, v59, v40                                 // 000000186B18: 3850513B
	v_and_b32_e32 v54, 0x7f7f7f7f, v39                         // 000000186B1C: 366C4EFF 7F7F7F7F
	v_lshrrev_b32_e32 v51, 7, v51                              // 000000186B24: 32666687
	v_and_b32_e32 v50, 0x1010101, v50                          // 000000186B28: 366464FF 01010101
	v_mul_lo_u32 v49, 0xff, v49                                // 000000186B30: D72C0031 000262FF 000000FF
	v_lshrrev_b32_e32 v40, 7, v40                              // 000000186B3C: 32505087
	v_and_b32_e32 v55, 0x7f7f7f7f, v48                         // 000000186B40: 366E60FF 7F7F7F7F
	v_and_b32_e32 v51, 0x1010101, v51                          // 000000186B48: 366666FF 01010101
	v_mul_lo_u32 v50, 0xff, v50                                // 000000186B50: D72C0032 000264FF 000000FF
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_1) | instid1(VALU_DEP_4)// 000000186B5C: BF870224
	v_and_b32_e32 v40, 0x1010101, v40                          // 000000186B60: 365050FF 01010101
	v_and_b32_e32 v56, 0x7f7f7f7f, v49                         // 000000186B68: 367062FF 7F7F7F7F
	v_mul_lo_u32 v51, 0xff, v51                                // 000000186B70: D72C0033 000266FF 000000FF
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 000000186B7C: BF8701A3
	v_mul_lo_u32 v40, 0xff, v40                                // 000000186B80: D72C0028 000250FF 000000FF
	v_and_b32_e32 v57, 0x7f7f7f7f, v50                         // 000000186B8C: 367264FF 7F7F7F7F
	v_and_b32_e32 v58, 0x7f7f7f7f, v51                         // 000000186B94: 367466FF 7F7F7F7F
	s_delay_alu instid0(VALU_DEP_3)                            // 000000186B9C: BF870003
	v_and_b32_e32 v59, 0x7f7f7f7f, v40                         // 000000186BA0: 367650FF 7F7F7F7F
	s_waitcnt vmcnt(9)                                         // 000000186BA8: BF8927F7
	v_xor_b32_e32 v36, v36, v41                                // 000000186BAC: 3A485324
	v_and_b32_e32 v41, 0x80808080, v41                         // 000000186BB0: 365252FF 80808080
	s_waitcnt vmcnt(8)                                         // 000000186BB8: BF8923F7
	v_xor_b32_e32 v37, v37, v43                                // 000000186BBC: 3A4A5725
	s_delay_alu instid0(VALU_DEP_3)                            // 000000186BC0: BF870003
	v_or_b32_e32 v36, 0x80808080, v36                          // 000000186BC4: 384848FF 80808080
	s_waitcnt vmcnt(7)                                         // 000000186BCC: BF891FF7
	v_xor_b32_e32 v39, v39, v45                                // 000000186BD0: 3A4E5B27
	v_and_b32_e32 v43, 0x80808080, v43                         // 000000186BD4: 365656FF 80808080
	v_and_b32_e32 v45, 0x80808080, v45                         // 000000186BDC: 365A5AFF 80808080
	v_or_b32_e32 v37, 0x80808080, v37                          // 000000186BE4: 384A4AFF 80808080
	v_sub_nc_u32_e32 v36, v36, v52                             // 000000186BEC: 4C486924
	v_or_b32_e32 v39, 0x80808080, v39                          // 000000186BF0: 384E4EFF 80808080
	s_waitcnt vmcnt(6)                                         // 000000186BF8: BF891BF7
	v_xor_b32_e32 v48, v48, v46                                // 000000186BFC: 3A605D30
	s_waitcnt vmcnt(5)                                         // 000000186C00: BF8917F7
	v_xor_b32_e32 v49, v49, v44                                // 000000186C04: 3A625931
	v_sub_nc_u32_e32 v37, v37, v53                             // 000000186C08: 4C4A6B25
	v_xor3_b32 v36, v41, v36, 0x80808080                       // 000000186C0C: D6400024 03FE4929 80808080
	v_sub_nc_u32_e32 v39, v39, v54                             // 000000186C18: 4C4E6D27
	v_or_b32_e32 v48, 0x80808080, v48                          // 000000186C1C: 386060FF 80808080
	v_and_b32_e32 v46, 0x80808080, v46                         // 000000186C24: 365C5CFF 80808080
	v_xor3_b32 v37, v43, v37, 0x80808080                       // 000000186C2C: D6400025 03FE4B2B 80808080
	v_dot4_i32_iu8 v36, v36, v5, 0 neg_lo:[1,1,0]              // 000000186C38: CC164024 7A020B24
	s_waitcnt vmcnt(4)                                         // 000000186C40: BF8913F7
	v_xor_b32_e32 v41, v50, v42                                // 000000186C44: 3A525532
	v_or_b32_e32 v43, 0x80808080, v49                          // 000000186C48: 385662FF 80808080
	v_sub_nc_u32_e32 v48, v48, v55                             // 000000186C50: 4C606F30
	v_xor3_b32 v39, v45, v39, 0x80808080                       // 000000186C54: D6400027 03FE4F2D 80808080
	v_dot4_i32_iu8 v36, v37, v6, v36 neg_lo:[1,1,0]            // 000000186C60: CC164024 7C920D25
	v_and_b32_e32 v44, 0x80808080, v44                         // 000000186C68: 365858FF 80808080
	v_or_b32_e32 v41, 0x80808080, v41                          // 000000186C70: 385252FF 80808080
	v_sub_nc_u32_e32 v43, v43, v56                             // 000000186C78: 4C56712B
	v_xor3_b32 v45, v46, v48, 0x80808080                       // 000000186C7C: D640002D 03FE612E 80808080
	v_dot4_i32_iu8 v36, v39, v7, v36 neg_lo:[1,1,0]            // 000000186C88: CC164024 7C920F27
	s_waitcnt vmcnt(3)                                         // 000000186C90: BF890FF7
	v_xor_b32_e32 v37, v51, v47                                // 000000186C94: 3A4A5F33
	v_and_b32_e32 v42, 0x80808080, v42                         // 000000186C98: 365454FF 80808080
	s_waitcnt vmcnt(2)                                         // 000000186CA0: BF890BF7
	v_xor_b32_e32 v39, v40, v35                                // 000000186CA4: 3A4E4728
	v_sub_nc_u32_e32 v40, v41, v57                             // 000000186CA8: 4C507329
	v_xor3_b32 v41, v44, v43, 0x80808080                       // 000000186CAC: D6400029 03FE572C 80808080
	v_or_b32_e32 v37, 0x80808080, v37                          // 000000186CB8: 384A4AFF 80808080
	v_dot4_i32_iu8 v36, v45, v0, v36 neg_lo:[1,1,0]            // 000000186CC0: CC164024 7C92012D
	v_and_b32_e32 v43, 0x80808080, v47                         // 000000186CC8: 36565EFF 80808080
	v_or_b32_e32 v39, 0x80808080, v39                          // 000000186CD0: 384E4EFF 80808080
	v_xor3_b32 v40, v42, v40, 0x80808080                       // 000000186CD8: D6400028 03FE512A 80808080
	v_sub_nc_u32_e32 v37, v37, v58                             // 000000186CE4: 4C4A7525
	v_dot4_i32_iu8 v36, v41, v1, v36 neg_lo:[1,1,0]            // 000000186CE8: CC164024 7C920329
	v_and_b32_e32 v35, 0x80808080, v35                         // 000000186CF0: 364646FF 80808080
	v_sub_nc_u32_e32 v39, v39, v59                             // 000000186CF8: 4C4E7727
	s_waitcnt vmcnt(1)                                         // 000000186CFC: BF8907F7
	v_lshrrev_b32_e32 v38, v20, v38                            // 000000186D00: 324C4D14
	v_xor3_b32 v37, v43, v37, 0x80808080                       // 000000186D04: D6400025 03FE4B2B 80808080
	v_dot4_i32_iu8 v36, v40, v2, v36 neg_lo:[1,1,0]            // 000000186D10: CC164024 7C920528
	v_xor3_b32 v35, v35, v39, 0x80808080                       // 000000186D18: D6400023 03FE4F23 80808080
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000186D24: BF870122
	v_dot4_i32_iu8 v36, v37, v3, v36 neg_lo:[1,1,0]            // 000000186D28: CC164024 7C920725
	v_lshlrev_b32_e32 v37, 1, v38                              // 000000186D30: 304A4C81
	v_dot4_i32_iu8 v35, v35, v23, v36 neg_lo:[1,1,0]           // 000000186D34: CC164023 7C922F23
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000186D3C: BF870092
	v_and_or_b32 v36, v37, 30, 1                               // 000000186D40: D6570024 02053D25
	v_mul_lo_u32 v35, v35, v36                                 // 000000186D48: D72C0023 00024923
	s_waitcnt vmcnt(0)                                         // 000000186D50: BF8903F7
	v_cvt_f32_f16_e32 v36, v4.l                                // 000000186D54: 7E481704
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000186D58: BF870191
	v_mul_f32_e32 v36, v25, v36                                // 000000186D5C: 10484919
	v_cvt_f32_i32_e32 v35, v35                                 // 000000186D60: 7E460B23
	s_delay_alu instid0(VALU_DEP_1)                            // 000000186D64: BF870001
	v_fmac_f32_e32 v15, v36, v35                               // 000000186D68: 561E4724
	s_branch 64749                                             // 000000186D6C: BFA0FCED <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x324>
	s_or_b32 exec_lo, exec_lo, s16                             // 000000186D70: 8C7E107E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000186D74: BF870009
	s_or_b32 exec_lo, exec_lo, s31                             // 000000186D78: 8C7E1F7E
	s_waitcnt vmcnt(0)                                         // 000000186D7C: BF8903F7
	buffer_gl0_inv                                             // 000000186D80: E0AC0000 00000000
	s_mov_b32 s3, exec_lo                                      // 000000186D88: BE83007E
	v_cmpx_eq_u32_e32 0, v13                                   // 000000186D8C: 7D941A80
	s_cbranch_execz 406                                        // 000000186D90: BFA50196 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x15ec>
	v_mbcnt_lo_u32_b32 v1, -1, 0                               // 000000186D94: D71F0001 000100C1
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000186D9C: BF8701B1
	v_xor_b32_e32 v0, 16, v1                                   // 000000186DA0: 3A000290
	v_xor_b32_e32 v3, 8, v1                                    // 000000186DA4: 3A060288
	v_xor_b32_e32 v4, 4, v1                                    // 000000186DA8: 3A080284
	v_cmp_gt_i32_e32 vcc_lo, 32, v0                            // 000000186DAC: 7C8800A0
	v_cndmask_b32_e32 v0, v1, v0, vcc_lo                       // 000000186DB0: 02000101
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 000000186DB4: BF8700C4
	v_cmp_gt_i32_e32 vcc_lo, 32, v3                            // 000000186DB8: 7C8806A0
	v_cndmask_b32_e32 v3, v1, v3, vcc_lo                       // 000000186DBC: 02060701
	v_cmp_gt_i32_e32 vcc_lo, 32, v4                            // 000000186DC0: 7C8808A0
	v_cndmask_b32_e32 v4, v1, v4, vcc_lo                       // 000000186DC4: 02080901
	v_lshlrev_b32_e32 v4, 2, v4                                // 000000186DC8: 30080882
	s_delay_alu instid0(VALU_DEP_4)                            // 000000186DCC: BF870004
	v_lshlrev_b32_e32 v3, 2, v3                                // 000000186DD0: 30060682
	v_lshlrev_b32_e32 v0, 2, v0                                // 000000186DD4: 30000082
	ds_bpermute_b32 v2, v0, v17                                // 000000186DD8: DACC0000 02001100
	s_waitcnt lgkmcnt(0)                                       // 000000186DE0: BF89FC07
	v_add_f32_e32 v2, v17, v2                                  // 000000186DE4: 06040511
	ds_bpermute_b32 v5, v3, v2                                 // 000000186DE8: DACC0000 05000203
	s_waitcnt lgkmcnt(0)                                       // 000000186DF0: BF89FC07
	v_add_f32_e32 v2, v2, v5                                   // 000000186DF4: 06040B02
	v_xor_b32_e32 v5, 2, v1                                    // 000000186DF8: 3A0A0282
	ds_bpermute_b32 v6, v4, v2                                 // 000000186DFC: DACC0000 06000204
	v_cmp_gt_i32_e32 vcc_lo, 32, v5                            // 000000186E04: 7C880AA0
	v_cndmask_b32_e32 v5, v1, v5, vcc_lo                       // 000000186E08: 020A0B01
	s_waitcnt lgkmcnt(0)                                       // 000000186E0C: BF89FC07
	s_delay_alu instid0(VALU_DEP_1)                            // 000000186E10: BF870001
	v_dual_add_f32 v2, v2, v6 :: v_dual_lshlrev_b32 v5, 2, v5  // 000000186E14: C9220D02 02040A82
	v_xor_b32_e32 v6, 1, v1                                    // 000000186E1C: 3A0C0281
	ds_bpermute_b32 v7, v5, v2                                 // 000000186E20: DACC0000 07000205
	v_cmp_gt_i32_e32 vcc_lo, 32, v6                            // 000000186E28: 7C880CA0
	v_cndmask_b32_e32 v1, v1, v6, vcc_lo                       // 000000186E2C: 02020D01
	v_cmp_ne_u32_e32 vcc_lo, 1, v14                            // 000000186E30: 7C9A1C81
	s_delay_alu instid0(VALU_DEP_2)                            // 000000186E34: BF870002
	v_lshlrev_b32_e32 v6, 2, v1                                // 000000186E38: 300C0282
	s_waitcnt lgkmcnt(0)                                       // 000000186E3C: BF89FC07
	v_add_f32_e32 v1, v2, v7                                   // 000000186E40: 06020F02
	ds_bpermute_b32 v2, v6, v1                                 // 000000186E44: DACC0000 02000106
	s_cbranch_vccnz 20                                         // 000000186E4C: BFA40014 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x10a0>
	ds_bpermute_b32 v0, v0, v15                                // 000000186E50: DACC0000 00000F00
	s_waitcnt lgkmcnt(0)                                       // 000000186E58: BF89FC07
	v_add_f32_e32 v0, v15, v0                                  // 000000186E5C: 0600010F
	ds_bpermute_b32 v3, v3, v0                                 // 000000186E60: DACC0000 03000003
	s_waitcnt lgkmcnt(0)                                       // 000000186E68: BF89FC07
	v_add_f32_e32 v0, v0, v3                                   // 000000186E6C: 06000700
	ds_bpermute_b32 v3, v4, v0                                 // 000000186E70: DACC0000 03000004
	s_waitcnt lgkmcnt(0)                                       // 000000186E78: BF89FC07
	v_add_f32_e32 v0, v0, v3                                   // 000000186E7C: 06000700
	ds_bpermute_b32 v3, v5, v0                                 // 000000186E80: DACC0000 03000005
	s_waitcnt lgkmcnt(0)                                       // 000000186E88: BF89FC07
	v_add_f32_e32 v0, v0, v3                                   // 000000186E8C: 06000700
	ds_bpermute_b32 v3, v6, v0                                 // 000000186E90: DACC0000 03000006
	s_waitcnt lgkmcnt(0)                                       // 000000186E98: BF89FC07
	v_add_f32_e32 v15, v0, v3                                  // 000000186E9C: 061E0700
	v_cmp_eq_u32_e32 vcc_lo, 0, v10                            // 000000186EA0: 7C941480
	s_and_b32 exec_lo, exec_lo, vcc_lo                         // 000000186EA4: 8B7E6A7E
	s_cbranch_execz 336                                        // 000000186EA8: BFA50150 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x15ec>
	s_waitcnt lgkmcnt(0)                                       // 000000186EAC: BF89FC07
	v_add_f32_e32 v0, v1, v2                                   // 000000186EB0: 06000501
	v_cmp_ne_u32_e32 vcc_lo, 1, v14                            // 000000186EB4: 7C9A1C81
	s_delay_alu instid0(VALU_DEP_2)                            // 000000186EB8: BF870002
	v_add_f32_e32 v0, v12, v0                                  // 000000186EBC: 0600010C
	s_cbranch_vccnz 312                                        // 000000186EC0: BFA40138 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x15a4>
	v_add_f32_e32 v1, v11, v15                                 // 000000186EC4: 06021F0B
	s_cmp_lt_i32 s12, 3                                        // 000000186EC8: BF04830C
	s_mov_b32 s3, 0                                            // 000000186ECC: BE830080
	s_cbranch_scc1 75                                          // 000000186ED0: BFA2004B <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1200>
	s_cmp_gt_i32 s12, 5                                        // 000000186ED4: BF02850C
	s_cbranch_scc0 76                                          // 000000186ED8: BFA1004C <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x120c>
	s_cmp_eq_u32 s12, 6                                        // 000000186EDC: BF06860C
	s_cbranch_scc0 77                                          // 000000186EE0: BFA1004D <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1218>
	v_max_f32_e32 v2, v1, v1                                   // 000000186EE4: 20040301
	v_max_f32_e64 v3, s13, s13                                 // 000000186EE8: D5100003 00001A0D
	s_mov_b32 s8, 0                                            // 000000186EF0: BE880080
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000186EF4: BF870091
	v_min_f32_e32 v2, v2, v3                                   // 000000186EF8: 1E040702
	v_mul_f32_e32 v4, 0xbfb8aa3b, v2                           // 000000186EFC: 100804FF BFB8AA3B
	v_cmp_nlt_f32_e32 vcc_lo, 0x42ce8ed0, v2                   // 000000186F04: 7C3C04FF 42CE8ED0
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000186F0C: BF8700A2
	v_fma_f32 v5, 0xbfb8aa3b, v2, -v4                          // 000000186F10: D6130005 841204FF BFB8AA3B
	v_rndne_f32_e32 v6, v4                                     // 000000186F1C: 7E0C4704
	v_dual_fmamk_f32 v5, v2, 0xb2a5705f, v5 :: v_dual_sub_f32 v4, v4, v6// 000000186F20: C88A0B02 05040D04 B2A5705F
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000186F2C: BF870121
	v_add_f32_e32 v4, v4, v5                                   // 000000186F30: 06080B04
	v_cvt_i32_f32_e32 v5, v6                                   // 000000186F34: 7E0A1106
	v_exp_f32_e32 v4, v4                                       // 000000186F38: 7E084B04
	s_waitcnt_depctr 0xfff                                     // 000000186F3C: BF880FFF
	v_ldexp_f32 v4, v4, v5                                     // 000000186F40: D71C0004 00020B04
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000186F48: BF870121
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo                        // 000000186F4C: 02080880
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2b17218, v2                   // 000000186F50: 7C3604FF C2B17218
	v_cndmask_b32_e32 v4, 0x7f800000, v4, vcc_lo               // 000000186F58: 020808FF 7F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000186F60: BF870091
	v_add_f32_e32 v4, 1.0, v4                                  // 000000186F64: 060808F2
	v_div_scale_f32 v5, null, v4, v4, v2                       // 000000186F68: D6FC7C05 040A0904
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000186F70: BF8700B1
	v_rcp_f32_e32 v6, v5                                       // 000000186F74: 7E0C5505
	s_waitcnt_depctr 0xfff                                     // 000000186F78: BF880FFF
	v_fma_f32 v7, -v5, v6, 1.0                                 // 000000186F7C: D6130007 23CA0D05
	v_fmac_f32_e32 v6, v7, v6                                  // 000000186F84: 560C0D07
	v_div_scale_f32 v7, vcc_lo, v2, v4, v2                     // 000000186F88: D6FC6A07 040A0902
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000186F90: BF870091
	v_mul_f32_e32 v8, v7, v6                                   // 000000186F94: 10100D07
	v_fma_f32 v9, -v5, v8, v7                                  // 000000186F98: D6130009 241E1105
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000186FA0: BF870121
	v_fmac_f32_e32 v8, v9, v6                                  // 000000186FA4: 56100D09
	v_max_f32_e64 v9, -s13, -s13                               // 000000186FA8: D5100009 60001A0D
	v_fma_f32 v5, -v5, v8, v7                                  // 000000186FB0: D6130005 241E1105
	v_max_f32_e32 v7, v0, v0                                   // 000000186FB8: 200E0100
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000186FBC: BF870112
	v_div_fmas_f32 v5, v5, v6, v8                              // 000000186FC0: D6370005 04220D05
	v_minmax_f32 v3, v7, v3, v9                                // 000000186FC8: D65F0003 04260707
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000186FD0: BF870092
	v_div_fixup_f32 v2, v5, v4, v2                             // 000000186FD4: D6270002 040A0905
	v_mul_f32_e32 v2, v3, v2                                   // 000000186FDC: 10040503
	s_branch 14                                                // 000000186FE0: BFA0000E <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x121c>
	s_clause 0x1                                               // 000000186FE4: BF850001
	s_load_b128 s[36:39], s[0:1], 0x70                         // 000000186FE8: F4080900 F8000070
	s_load_b128 s[16:19], s[0:1], 0x98                         // 000000186FF0: F4080400 F8000098
	s_branch 64409                                             // 000000186FF8: BFA0FB99 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x60>
	s_branch 64428                                             // 000000186FFC: BFA0FBAC <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xb0>
	s_mov_b32 s8, 0                                            // 000000187000: BE880080
	s_cbranch_execnz 78                                        // 000000187004: BFA6004E <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1340>
	s_branch 140                                               // 000000187008: BFA0008C <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x143c>
	s_mov_b32 s8, 0                                            // 00000018700C: BE880080
	s_cbranch_execnz 3                                         // 000000187010: BFA60003 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1220>
	s_branch 71                                                // 000000187014: BFA00047 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1334>
	s_mov_b32 s8, -1                                           // 000000187018: BE8800C1
	s_branch 69                                                // 00000018701C: BFA00045 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1334>
	s_cmp_eq_u32 s12, 3                                        // 000000187020: BF06830C
	s_cbranch_scc0 68                                          // 000000187024: BFA10044 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1338>
	v_max_f32_e32 v2, v1, v1                                   // 000000187028: 20040301
	s_mov_b32 s8, 0xc0e00000                                   // 00000018702C: BE8800FF C0E00000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187034: BF870091
	v_min_f32_e32 v2, 0x40e00000, v2                           // 000000187038: 1E0404FF 40E00000
	v_mul_f32_e32 v3, 0xbfd9db23, v2                           // 000000187040: 100604FF BFD9DB23
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187048: BF870091
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3                           // 00000018704C: 100806FF 3FB8AA3B
	v_fma_f32 v5, 0x3fb8aa3b, v3, -v4                          // 000000187054: D6130005 841206FF 3FB8AA3B
	v_rndne_f32_e32 v6, v4                                     // 000000187060: 7E0C4704
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187064: BF870091
	v_dual_fmamk_f32 v5, v3, 0x32a5705f, v5 :: v_dual_sub_f32 v4, v4, v6// 000000187068: C88A0B03 05040D04 32A5705F
	v_add_f32_e32 v4, v4, v5                                   // 000000187074: 06080B04
	v_cvt_i32_f32_e32 v5, v6                                   // 000000187078: 7E0A1106
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v3                   // 00000018707C: 7C3606FF C2CE8ED0
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000187084: BF8700B3
	v_exp_f32_e32 v4, v4                                       // 000000187088: 7E084B04
	s_waitcnt_depctr 0xfff                                     // 00000018708C: BF880FFF
	v_ldexp_f32 v4, v4, v5                                     // 000000187090: D71C0004 00020B04
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo                        // 000000187098: 02080880
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v3                   // 00000018709C: 7C3C06FF 42B17218
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001870A4: BF870092
	v_cndmask_b32_e32 v3, 0x7f800000, v4, vcc_lo               // 0000001870A8: 020608FF 7F800000
	v_add_f32_e32 v3, 1.0, v3                                  // 0000001870B0: 060606F2
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000001870B4: BF870121
	v_div_scale_f32 v4, null, v3, v3, v2                       // 0000001870B8: D6FC7C04 040A0703
	v_div_scale_f32 v7, vcc_lo, v2, v3, v2                     // 0000001870C0: D6FC6A07 040A0702
	v_rcp_f32_e32 v5, v4                                       // 0000001870C8: 7E0A5504
	s_waitcnt_depctr 0xfff                                     // 0000001870CC: BF880FFF
	v_fma_f32 v6, -v4, v5, 1.0                                 // 0000001870D0: D6130006 23CA0B04
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001870D8: BF870091
	v_fmac_f32_e32 v5, v6, v5                                  // 0000001870DC: 560A0B06
	v_mul_f32_e32 v6, v7, v5                                   // 0000001870E0: 100C0B07
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001870E4: BF870091
	v_fma_f32 v8, -v4, v6, v7                                  // 0000001870E8: D6130008 241E0D04
	v_fmac_f32_e32 v6, v8, v5                                  // 0000001870F0: 560C0B08
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001870F4: BF870091
	v_fma_f32 v4, -v4, v6, v7                                  // 0000001870F8: D6130004 241E0D04
	v_div_fmas_f32 v4, v4, v5, v6                              // 000000187100: D6370004 041A0B04
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000187108: BF8700A1
	v_div_fixup_f32 v2, v4, v3, v2                             // 00000018710C: D6270002 040A0704
	v_max_f32_e32 v7, v0, v0                                   // 000000187114: 200E0100
	v_minmax_f32 v5, v7, 0x40e00000, s8                        // 000000187118: D65F0005 0021FF07 40E00000
	s_mov_b32 s8, 0                                            // 000000187124: BE880080
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187128: BF870091
	v_add_f32_e32 v3, 1.0, v5                                  // 00000018712C: 06060AF2
	v_mul_f32_e32 v2, v3, v2                                   // 000000187130: 10040503
	s_branch 65                                                // 000000187134: BFA00041 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x143c>
	s_mov_b32 s8, -1                                           // 000000187138: BE8800C1
	s_branch 63                                                // 00000018713C: BFA0003F <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x143c>
	s_cmp_gt_i32 s12, 1                                        // 000000187140: BF02810C
	s_cbranch_scc0 53                                          // 000000187144: BFA10035 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x141c>
	v_mul_f32_e32 v2, 0xbfb8aa3b, v1                           // 000000187148: 100402FF BFB8AA3B
	v_cmp_nlt_f32_e32 vcc_lo, 0x42ce8ed0, v1                   // 000000187150: 7C3C02FF 42CE8ED0
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000187158: BF870122
	v_rndne_f32_e32 v3, v2                                     // 00000018715C: 7E064702
	v_fma_f32 v4, 0xbfb8aa3b, v1, -v2                          // 000000187160: D6130004 840A02FF BFB8AA3B
	v_sub_f32_e32 v2, v2, v3                                   // 00000018716C: 08040702
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000187170: BF870122
	v_fmamk_f32 v4, v1, 0xb2a5705f, v4                         // 000000187174: 58080901 B2A5705F
	v_cvt_i32_f32_e32 v3, v3                                   // 00000018717C: 7E061103
	v_add_f32_e32 v2, v2, v4                                   // 000000187180: 06040902
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000187184: BF8700B1
	v_exp_f32_e32 v2, v2                                       // 000000187188: 7E044B02
	s_waitcnt_depctr 0xfff                                     // 00000018718C: BF880FFF
	v_ldexp_f32 v2, v2, v3                                     // 000000187190: D71C0002 00020702
	v_cndmask_b32_e32 v2, 0, v2, vcc_lo                        // 000000187198: 02040480
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2b17218, v1                   // 00000018719C: 7C3602FF C2B17218
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001871A4: BF870092
	v_cndmask_b32_e32 v2, 0x7f800000, v2, vcc_lo               // 0000001871A8: 020404FF 7F800000
	v_add_f32_e32 v2, 1.0, v2                                  // 0000001871B0: 060404F2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001871B4: BF870091
	v_div_scale_f32 v3, null, v2, v2, v1                       // 0000001871B8: D6FC7C03 04060502
	v_rcp_f32_e32 v4, v3                                       // 0000001871C0: 7E085503
	s_waitcnt_depctr 0xfff                                     // 0000001871C4: BF880FFF
	v_fma_f32 v5, -v3, v4, 1.0                                 // 0000001871C8: D6130005 23CA0903
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 0000001871D0: BF8700A1
	v_fmac_f32_e32 v4, v5, v4                                  // 0000001871D4: 56080905
	v_div_scale_f32 v5, vcc_lo, v1, v2, v1                     // 0000001871D8: D6FC6A05 04060501
	v_mul_f32_e32 v6, v5, v4                                   // 0000001871E0: 100C0905
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001871E4: BF870091
	v_fma_f32 v7, -v3, v6, v5                                  // 0000001871E8: D6130007 24160D03
	v_fmac_f32_e32 v6, v7, v4                                  // 0000001871F0: 560C0907
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001871F4: BF870091
	v_fma_f32 v3, -v3, v6, v5                                  // 0000001871F8: D6130003 24160D03
	v_div_fmas_f32 v3, v3, v4, v6                              // 000000187200: D6370003 041A0903
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187208: BF870091
	v_div_fixup_f32 v2, v3, v2, v1                             // 00000018720C: D6270002 04060503
	v_mul_f32_e32 v2, v0, v2                                   // 000000187214: 10040500
	s_branch 1                                                 // 000000187218: BFA00001 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1420>
	s_mov_b32 s3, -1                                           // 00000018721C: BE8300C1
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000187220: BF870009
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 000000187224: 916A037E
	s_mov_b32 s3, 0                                            // 000000187228: BE830080
	s_cbranch_vccnz 3                                          // 00000018722C: BFA40003 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x143c>
	s_cmp_lg_u32 s12, 1                                        // 000000187230: BF07810C
	s_mov_b32 s3, -1                                           // 000000187234: BE8300C1
	s_cselect_b32 s8, -1, 0                                    // 000000187238: 980880C1
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000018723C: BF870009
	s_and_b32 vcc_lo, exec_lo, s8                              // 000000187240: 8B6A087E
	s_cbranch_vccz 2                                           // 000000187244: BFA30002 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1450>
	v_mul_f32_e32 v2, v0, v1                                   // 000000187248: 10040300
	s_mov_b32 s3, 0                                            // 00000018724C: BE830080
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000187250: BF870009
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 000000187254: 916A037E
	s_cbranch_vccnz 80                                         // 000000187258: BFA40050 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x159c>
	v_mul_f32_e32 v2, 0x3d372713, v1                           // 00000018725C: 100402FF 3D372713
	v_mul_f32_e32 v3, 0x3f4c422a, v1                           // 000000187264: 100602FF 3F4C422A
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000018726C: BF870092
	v_fma_f32 v2, v1, v2, 1.0                                  // 000000187270: D6130002 03CA0501
	v_mul_f32_e32 v2, v3, v2                                   // 000000187278: 10040503
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000018727C: BF8704A1
	v_cmp_ngt_f32_e64 s3, 0x3f200000, |v2|                     // 000000187280: D41B0203 000204FF 3F200000
	s_and_saveexec_b32 s8, s3                                  // 00000018728C: BE882003
	s_xor_b32 s3, exec_lo, s8                                  // 000000187290: 8D03087E
	s_cbranch_execz 34                                         // 000000187294: BFA50022 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1520>
	v_add_f32_e64 v3, |v2|, |v2|                               // 000000187298: D5030303 00020502
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000001872A0: BF870121
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3                           // 0000001872A4: 100806FF 3FB8AA3B
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v3                   // 0000001872AC: 7C3606FF C2CE8ED0
	v_rndne_f32_e32 v5, v4                                     // 0000001872B4: 7E0A4704
	v_fma_f32 v6, 0x3fb8aa3b, v3, -v4                          // 0000001872B8: D6130006 841206FF 3FB8AA3B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000001872C4: BF870112
	v_sub_f32_e32 v4, v4, v5                                   // 0000001872C8: 08080B04
	v_fmamk_f32 v6, v3, 0x32a5705f, v6                         // 0000001872CC: 580C0D03 32A5705F
	v_cvt_i32_f32_e32 v5, v5                                   // 0000001872D4: 7E0A1105
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001872D8: BF870092
	v_add_f32_e32 v4, v4, v6                                   // 0000001872DC: 06080D04
	v_exp_f32_e32 v4, v4                                       // 0000001872E0: 7E084B04
	s_waitcnt_depctr 0xfff                                     // 0000001872E4: BF880FFF
	v_ldexp_f32 v4, v4, v5                                     // 0000001872E8: D71C0004 00020B04
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000001872F0: BF870121
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo                        // 0000001872F4: 02080880
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v3                   // 0000001872F8: 7C3C06FF 42B17218
	v_cndmask_b32_e32 v3, 0x7f800000, v4, vcc_lo               // 000000187300: 020608FF 7F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187308: BF870091
	v_add_f32_e32 v3, 1.0, v3                                  // 00000018730C: 060606F2
	v_rcp_f32_e32 v3, v3                                       // 000000187310: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000187314: BF880FFF
	v_fma_f32 v3, v3, -2.0, 1.0                                // 000000187318: D6130003 03C9EB03
	s_and_not1_saveexec_b32 s3, s3                             // 000000187320: BE833003
	s_cbranch_execz 19                                         // 000000187324: BFA50013 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1574>
	v_mul_f32_e32 v3, v2, v2                                   // 000000187328: 10060502
	s_mov_b32 s8, 0xbbbac73d                                   // 00000018732C: BE8800FF BBBAC73D
	s_delay_alu instid0(VALU_DEP_1) | instid1(SALU_CYCLE_1)    // 000000187334: BF870481
	v_fmaak_f32 v4, s8, v3, 0x3ca908c9                         // 000000187338: 5A080608 3CA908C9
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187340: BF870091
	v_fmaak_f32 v4, v3, v4, 0xbd5c1c4e                         // 000000187344: 5A080903 BD5C1C4E
	v_fmaak_f32 v4, v3, v4, 0x3e088382                         // 00000018734C: 5A080903 3E088382
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187354: BF870091
	v_fmaak_f32 v4, v3, v4, 0xbeaaaa99                         // 000000187358: 5A080903 BEAAAA99
	v_mul_f32_e64 v4, |v2|, v4                                 // 000000187360: D5080104 00020902
	s_delay_alu instid0(VALU_DEP_1)                            // 000000187368: BF870001
	v_fma_f32 v3, v3, v4, |v2|                                 // 00000018736C: D6130403 040A0903
	s_or_b32 exec_lo, exec_lo, s3                              // 000000187374: 8C7E037E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187378: BF870091
	v_bfi_b32 v2, 0x7fffffff, v3, v2                           // 00000018737C: D6120002 040A06FF 7FFFFFFF
	v_dual_mul_f32 v1, 0.5, v1 :: v_dual_add_f32 v2, 1.0, v2   // 000000187388: C8C802F0 010204F2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187390: BF870091
	v_mul_f32_e32 v1, v1, v2                                   // 000000187394: 10020501
	v_mul_f32_e32 v2, v0, v1                                   // 000000187398: 10040300
	s_delay_alu instid0(VALU_DEP_1)                            // 00000018739C: BF870001
	v_mov_b32_e32 v0, v2                                       // 0000001873A0: 7E000302
	s_load_b64 s[0:1], s[0:1], 0x68                            // 0000001873A4: F4040000 F8000068
	s_and_b32 s3, exec_lo, s5                                  // 0000001873AC: 8B03057E
	s_mul_i32 s3, s22, s4                                      // 0000001873B0: 96030416
	s_mul_i32 s33, s33, s18                                    // 0000001873B4: 96211221
	v_mov_b32_e32 v1, 0                                        // 0000001873B8: 7E020280
	s_waitcnt lgkmcnt(0)                                       // 0000001873BC: BF89FC07
	s_cselect_b32 s4, s7, s1                                   // 0000001873C0: 98040107
	s_cselect_b32 s5, s6, s0                                   // 0000001873C4: 98050006
	s_add_i32 s0, s3, s2                                       // 0000001873C8: 81000203
	s_mov_b32 s1, 0                                            // 0000001873CC: BE810080
	s_add_i32 s0, s0, s33                                      // 0000001873D0: 81002100
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 0000001873D4: BF870499
	s_lshl_b64 s[0:1], s[0:1], 2                               // 0000001873D8: 84808200
	s_add_u32 s0, s5, s0                                       // 0000001873DC: 80000005
	s_addc_u32 s1, s4, s1                                      // 0000001873E0: 82010104
	global_store_b32 v1, v0, s[0:1]                            // 0000001873E4: DC6A0000 00000001
	s_endpgm                                                   // 0000001873EC: BFB00000
		...
