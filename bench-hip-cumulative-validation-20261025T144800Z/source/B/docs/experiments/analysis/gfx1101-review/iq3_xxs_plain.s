
build-hip-baseline/bin/libggml-hip.so.36.hipv4-amdgcn-amd-amdhsa--gfx1101:	file format elf64-amdgpu

Disassembly of section .text:

0000000000154e00 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj>:
	s_clause 0x1                                               // 000000154E00: BF850001
	s_load_b64 s[8:9], s[0:1], 0x10                            // 000000154E04: F4040200 F8000010
	s_load_b128 s[16:19], s[0:1], 0x70                         // 000000154E0C: F4080400 F8000070
	s_mov_b32 s6, s3                                           // 000000154E14: BE860003
	s_waitcnt lgkmcnt(0)                                       // 000000154E18: BF89FC07
	s_cmp_lg_u64 s[8:9], 0                                     // 000000154E1C: BF118008
	s_cselect_b32 s5, -1, 0                                    // 000000154E20: 980580C1
	s_cmp_eq_u64 s[8:9], 0                                     // 000000154E24: BF108008
	s_cbranch_scc1 32                                          // 000000154E28: BFA20020 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xac>
	s_mov_b32 s7, 0                                            // 000000154E2C: BE870080
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000154E30: BF870499
	s_lshl_b64 s[10:11], s[6:7], 2                             // 000000154E34: 848A8206
	s_add_u32 s8, s8, s10                                      // 000000154E38: 80080A08
	s_addc_u32 s9, s9, s11                                     // 000000154E3C: 82090B09
	s_load_b32 s3, s[8:9], null                                // 000000154E40: F40000C4 F8000000
	s_clause 0x1                                               // 000000154E48: BF850001
	s_load_b128 s[8:11], s[0:1], 0x98                          // 000000154E4C: F4080200 F8000098
	s_load_b32 s20, s[0:1], 0x80                               // 000000154E54: F4000500 F8000080
	s_cbranch_execnz 7                                         // 000000154E5C: BFA60007 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x7c>
	s_load_b64 s[12:13], s[0:1], 0x8c                          // 000000154E60: F4040300 F800008C
	s_waitcnt lgkmcnt(0)                                       // 000000154E68: BF89FC07
	s_mul_hi_u32 s3, s12, s6                                   // 000000154E6C: 9683060C
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000154E70: BF870499
	s_add_i32 s3, s6, s3                                       // 000000154E74: 81030306
	s_lshr_b32 s3, s3, s13                                     // 000000154E78: 85030D03
	s_load_b32 s21, s[0:1], 0xa8                               // 000000154E7C: F4000540 F80000A8
	s_and_not1_b32 vcc_lo, exec_lo, s5                         // 000000154E84: 916A057E
	s_cbranch_vccnz 14                                         // 000000154E88: BFA4000E <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xc4>
	s_mul_hi_u32 s5, s17, s6                                   // 000000154E8C: 96850611
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000154E90: BF870499
	s_add_i32 s5, s6, s5                                       // 000000154E94: 81050506
	s_lshr_b32 s5, s5, s18                                     // 000000154E98: 85051205
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000154E9C: BF870499
	s_mul_i32 s5, s5, s19                                      // 000000154EA0: 96051305
	s_sub_i32 s17, s6, s5                                      // 000000154EA4: 81910506
	s_branch 7                                                 // 000000154EA8: BFA00007 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xc8>
	s_clause 0x1                                               // 000000154EAC: BF850001
	s_load_b128 s[8:11], s[0:1], 0x98                          // 000000154EB0: F4080200 F8000098
	s_load_b32 s20, s[0:1], 0x80                               // 000000154EB8: F4000500 F8000080
	s_branch 65511                                             // 000000154EC0: BFA0FFE7 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x60>
	s_mov_b32 s17, s6                                          // 000000154EC4: BE910006
	s_load_b128 s[12:15], s[0:1], 0xb0                         // 000000154EC8: F4080300 F80000B0
	v_bfe_u32 v3, v0, 10, 10                                   // 000000154ED0: D6100003 02291500
	v_and_b32_e32 v2, 0x3ff, v0                                // 000000154ED8: 360400FF 000003FF
	v_mov_b32_e32 v4, 0                                        // 000000154EE0: 7E080280
	s_lshr_b32 s7, s16, 8                                      // 000000154EE4: 85078810
	s_mov_b32 s5, exec_lo                                      // 000000154EE8: BE85007E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154EEC: BF870092
	v_lshl_or_b32 v0, v3, 5, v2                                // 000000154EF0: D6560000 04090B03
	v_lshrrev_b32_e32 v5, 3, v0                                // 000000154EF8: 320A0083
	s_delay_alu instid0(VALU_DEP_1)                            // 000000154EFC: BF870001
	v_cmpx_gt_u32_e64 s7, v5                                   // 000000154F00: D4CC007E 00020A07
	s_cbranch_execz 396                                        // 000000154F08: BFA5018C <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x73c>
	v_lshrrev_b32_e32 v4, 3, v0                                // 000000154F0C: 32080083
	s_waitcnt lgkmcnt(0)                                       // 000000154F10: BF89FC07
	s_mul_i32 s9, s17, s9                                      // 000000154F14: 96090911
	v_and_b32_e32 v8, 7, v2                                    // 000000154F18: 36100487
	s_mul_hi_u32 s17, s9, 36                                   // 000000154F1C: 9691A409
	s_mul_i32 s16, s9, 36                                      // 000000154F20: 9610A409
	s_mul_i32 s9, s13, s4                                      // 000000154F24: 9609040D
	v_mad_u64_u32 v[0:1], null, 0x120, v4, s[16:17]            // 000000154F28: D6FE7C00 004208FF 00000120
	s_load_b128 s[16:19], s[0:1], null                         // 000000154F34: F4080400 F8000000
	v_lshlrev_b32_e32 v4, 1, v2                                // 000000154F3C: 30080481
	s_mul_i32 s20, s20, s2                                     // 000000154F40: 96140214
	s_mul_i32 s3, s3, s8                                       // 000000154F44: 96030803
	v_mad_u64_u32 v[6:7], null, s9, 36, v[0:1]                 // 000000154F48: D6FE7C06 04014809
	s_mul_hi_u32 s9, s11, s4                                   // 000000154F50: 9689040B
	s_mov_b32 s11, 0                                           // 000000154F54: BE8B0080
	s_add_i32 s9, s4, s9                                       // 000000154F58: 81090904
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(SALU_CYCLE_1)// 000000154F5C: BF8704C9
	s_lshr_b32 s9, s9, s21                                     // 000000154F60: 85091509
	v_mad_u64_u32 v[0:1], null, v8, 36, v[6:7]                 // 000000154F64: D6FE7C00 04194908
	v_dual_mov_b32 v4, 0 :: v_dual_and_b32 v7, 14, v4          // 000000154F6C: CA240080 0406088E
	s_mul_i32 s8, s9, s12                                      // 000000154F74: 96080C09
	s_add_i32 s8, s8, s20                                      // 000000154F78: 81081408
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 000000154F7C: BF8701A1
	v_lshlrev_b32_e32 v6, 1, v7                                // 000000154F80: 300C0E81
	s_waitcnt lgkmcnt(0)                                       // 000000154F84: BF89FC07
	v_add_co_u32 v0, vcc_lo, s18, v0                           // 000000154F88: D7006A00 00020012
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000154F90: BF870191
	v_add_co_ci_u32_e64 v1, null, s19, v1, vcc_lo              // 000000154F94: D5207C01 01AA0213
	v_lshlrev_b32_e32 v6, 1, v6                                // 000000154F9C: 300C0C81
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000154FA0: BF870093
	v_add_co_u32 v0, vcc_lo, v0, 32                            // 000000154FA4: D7006A00 00014100
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo                // 000000154FAC: D5207C01 01AA0280
	v_lshlrev_b32_e32 v7, 1, v7                                // 000000154FB4: 300E0E81
	s_add_i32 s12, s3, s8                                      // 000000154FB8: 810C0803
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000154FBC: BF870009
	v_add_nc_u32_e32 v8, s12, v5                               // 000000154FC0: 4A100A0C
	s_getpc_b64 s[8:9]                                         // 000000154FC4: BE884700
	s_add_u32 s8, s8, 0xfff4bb38                               // 000000154FC8: 8008FF08 FFF4BB38
	s_addc_u32 s9, s9, -1                                      // 000000154FD0: 8209FF09 FFFFFFFF
	v_add_nc_u32_e32 v5, 4, v5                                 // 000000154FD8: 4A0A0A84
	v_mad_i64_i32 v[16:17], null, 0x62, v8, s[16:17]           // 000000154FDC: D6FF7C10 004210FF 00000062
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000154FE8: BF8700B2
	v_cmp_le_u32_e64 s3, s7, v5                                // 000000154FEC: D44B0003 00020A07
	s_or_b32 s11, s3, s11                                      // 000000154FF4: 8C0B0B03
	v_add_co_u32 v8, vcc_lo, v16, v6                           // 000000154FF8: D7006A08 00020D10
	v_add_co_ci_u32_e64 v9, null, 0, v17, vcc_lo               // 000000155000: D5207C09 01AA2280
	global_load_b64 v[18:19], v[8:9], off offset:2             // 000000155008: DC560002 127C0008
	v_add_co_u32 v8, vcc_lo, v16, v7                           // 000000155010: D7006A08 00020F10
	s_delay_alu instid0(VALU_DEP_1)                            // 000000155018: BF870001
	v_add_co_ci_u32_e64 v9, null, 0, v17, vcc_lo               // 00000015501C: D5207C09 01AA2280
	global_load_b32 v20, v[8:9], off offset:66                 // 000000155024: DC520042 147C0008
	s_clause 0x1                                               // 00000015502C: BF850001
	global_load_b128 v[8:11], v[0:1], off offset:-32           // 000000155030: DC5E1FE0 087C0000
	global_load_b128 v[12:15], v[0:1], off offset:-16          // 000000155038: DC5E1FF0 0C7C0000
	global_load_d16_hi_b16 v8, v[16:17], off                   // 000000155040: DC8E0000 087C0010
	s_waitcnt vmcnt(4)                                         // 000000155048: BF8913F7
	v_and_b32_e32 v16, 0xff, v18                               // 00000015504C: 362024FF 000000FF
	v_lshrrev_b32_e32 v17, 6, v18                              // 000000155054: 32222486
	v_lshrrev_b32_e32 v21, 14, v18                             // 000000155058: 322A248E
	v_lshrrev_b32_e32 v18, 22, v18                             // 00000015505C: 32242496
	v_and_b32_e32 v22, 0xff, v19                               // 000000155060: 362C26FF 000000FF
	v_lshrrev_b32_e32 v23, 6, v19                              // 000000155068: 322E2686
	v_lshrrev_b32_e32 v24, 14, v19                             // 00000015506C: 3230268E
	v_lshrrev_b32_e32 v19, 22, v19                             // 000000155070: 32262696
	v_lshlrev_b32_e32 v16, 2, v16                              // 000000155074: 30202082
	v_and_b32_e32 v17, 0x3fc, v17                              // 000000155078: 362222FF 000003FC
	v_and_b32_e32 v21, 0x3fc, v21                              // 000000155080: 362A2AFF 000003FC
	v_and_b32_e32 v18, 0x3fc, v18                              // 000000155088: 362424FF 000003FC
	v_lshlrev_b32_e32 v22, 2, v22                              // 000000155090: 302C2C82
	v_and_b32_e32 v23, 0x3fc, v23                              // 000000155094: 362E2EFF 000003FC
	v_and_b32_e32 v24, 0x3fc, v24                              // 00000015509C: 363030FF 000003FC
	v_and_b32_e32 v19, 0x3fc, v19                              // 0000001550A4: 362626FF 000003FC
	s_clause 0x7                                               // 0000001550AC: BF850007
	global_load_b32 v16, v16, s[8:9]                           // 0000001550B0: DC520000 10080010
	global_load_b32 v17, v17, s[8:9]                           // 0000001550B8: DC520000 11080011
	global_load_b32 v21, v21, s[8:9]                           // 0000001550C0: DC520000 15080015
	global_load_b32 v18, v18, s[8:9]                           // 0000001550C8: DC520000 12080012
	global_load_b32 v22, v22, s[8:9]                           // 0000001550D0: DC520000 16080016
	global_load_b32 v23, v23, s[8:9]                           // 0000001550D8: DC520000 17080017
	global_load_b32 v24, v24, s[8:9]                           // 0000001550E0: DC520000 18080018
	global_load_b32 v19, v19, s[8:9]                           // 0000001550E8: DC520000 13080013
	global_load_b32 v25, v[0:1], off                           // 0000001550F0: DC520000 197C0000
	s_waitcnt vmcnt(12)                                        // 0000001550F8: BF8933F7
	v_and_b32_e32 v26, 0xff, v20                               // 0000001550FC: 363428FF 000000FF
	v_bfe_u32 v27, v20, 7, 8                                   // 000000155104: D610001B 02210F14
	v_bfe_u32 v28, v20, 14, 8                                  // 00000015510C: D610001C 02211D14
	v_bfe_u32 v29, v20, 21, 8                                  // 000000155114: D610001D 02212B14
	v_add_co_u32 v0, vcc_lo, 0x480, v0                         // 00000015511C: D7006A00 000200FF 00000480
	v_bcnt_u32_b32 v30, v26, 0                                 // 000000155128: D71E001E 0001011A
	v_bcnt_u32_b32 v31, v27, 0                                 // 000000155130: D71E001F 0001011B
	v_bcnt_u32_b32 v32, v28, 0                                 // 000000155138: D71E0020 0001011C
	v_bcnt_u32_b32 v33, v29, 0                                 // 000000155140: D71E0021 0001011D
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo                // 000000155148: D5207C01 01AA0280
	v_and_b32_e32 v30, 1, v30                                  // 000000155150: 363C3C81
	v_and_b32_e32 v31, 1, v31                                  // 000000155154: 363E3E81
	v_and_b32_e32 v32, 1, v32                                  // 000000155158: 36404081
	v_and_b32_e32 v33, 1, v33                                  // 00000015515C: 36424281
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 000000155160: BF870214
	v_lshlrev_b32_e32 v30, 7, v30                              // 000000155164: 303C3C87
	v_lshlrev_b32_e32 v31, 7, v31                              // 000000155168: 303E3E87
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 00000015516C: BF870214
	v_lshlrev_b32_e32 v32, 7, v32                              // 000000155170: 30404087
	v_lshlrev_b32_e32 v33, 7, v33                              // 000000155174: 30424287
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 000000155178: BF870214
	v_xor_b32_e32 v26, v30, v26                                // 00000015517C: 3A34351E
	v_xor_b32_e32 v27, v31, v27                                // 000000155180: 3A36371F
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 000000155184: BF870214
	v_xor_b32_e32 v28, v32, v28                                // 000000155188: 3A383920
	v_xor_b32_e32 v29, v33, v29                                // 00000015518C: 3A3A3B21
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 000000155190: BF870214
	v_mul_lo_u32 v26, 0x1010101, v26                           // 000000155194: D72C001A 000234FF 01010101
	v_mul_lo_u32 v27, 0x1010101, v27                           // 0000001551A0: D72C001B 000236FF 01010101
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)// 0000001551AC: BF870214
	v_mul_lo_u32 v28, 0x1010101, v28                           // 0000001551B0: D72C001C 000238FF 01010101
	v_mul_lo_u32 v29, 0x1010101, v29                           // 0000001551BC: D72C001D 00023AFF 01010101
	s_delay_alu instid0(VALU_DEP_4)                            // 0000001551C8: BF870004
	v_and_b32_e32 v30, 0x8040201, v26                          // 0000001551CC: 363C34FF 08040201
	v_and_b32_e32 v26, 0x80402010, v26                         // 0000001551D4: 363434FF 80402010
	v_and_b32_e32 v31, 0x8040201, v27                          // 0000001551DC: 363E36FF 08040201
	v_and_b32_e32 v27, 0x80402010, v27                         // 0000001551E4: 363636FF 80402010
	v_and_b32_e32 v32, 0x8040201, v28                          // 0000001551EC: 364038FF 08040201
	v_add_nc_u32_e32 v30, 0x7f7f7f7f, v30                      // 0000001551F4: 4A3C3CFF 7F7F7F7F
	v_add_nc_u32_e32 v26, 0x7f7f7f7f, v26                      // 0000001551FC: 4A3434FF 7F7F7F7F
	v_add_nc_u32_e32 v31, 0x7f7f7f7f, v31                      // 000000155204: 4A3E3EFF 7F7F7F7F
	v_add_nc_u32_e32 v27, 0x7f7f7f7f, v27                      // 00000015520C: 4A3636FF 7F7F7F7F
	v_and_b32_e32 v28, 0x80402010, v28                         // 000000155214: 363838FF 80402010
	v_lshrrev_b32_e32 v30, 7, v30                              // 00000015521C: 323C3C87
	v_lshrrev_b32_e32 v26, 7, v26                              // 000000155220: 32343487
	v_lshrrev_b32_e32 v31, 7, v31                              // 000000155224: 323E3E87
	v_add_nc_u32_e32 v32, 0x7f7f7f7f, v32                      // 000000155228: 4A4040FF 7F7F7F7F
	v_lshrrev_b32_e32 v27, 7, v27                              // 000000155230: 32363687
	v_and_b32_e32 v30, 0x1010101, v30                          // 000000155234: 363C3CFF 01010101
	v_and_b32_e32 v26, 0x1010101, v26                          // 00000015523C: 363434FF 01010101
	v_and_b32_e32 v31, 0x1010101, v31                          // 000000155244: 363E3EFF 01010101
	v_and_b32_e32 v33, 0x8040201, v29                          // 00000015524C: 36423AFF 08040201
	v_add_nc_u32_e32 v28, 0x7f7f7f7f, v28                      // 000000155254: 4A3838FF 7F7F7F7F
	v_mul_lo_u32 v30, 0xff, v30                                // 00000015525C: D72C001E 00023CFF 000000FF
	v_mul_lo_u32 v26, 0xff, v26                                // 000000155268: D72C001A 000234FF 000000FF
	v_lshrrev_b32_e32 v32, 7, v32                              // 000000155274: 32404087
	v_and_b32_e32 v27, 0x1010101, v27                          // 000000155278: 363636FF 01010101
	v_mul_lo_u32 v31, 0xff, v31                                // 000000155280: D72C001F 00023EFF 000000FF
	v_and_b32_e32 v29, 0x80402010, v29                         // 00000015528C: 363A3AFF 80402010
	v_add_nc_u32_e32 v33, 0x7f7f7f7f, v33                      // 000000155294: 4A4242FF 7F7F7F7F
	v_lshrrev_b32_e32 v28, 7, v28                              // 00000015529C: 32383887
	v_and_b32_e32 v34, 0x7f7f7f7f, v30                         // 0000001552A0: 36443CFF 7F7F7F7F
	v_and_b32_e32 v35, 0x7f7f7f7f, v26                         // 0000001552A8: 364634FF 7F7F7F7F
	v_and_b32_e32 v32, 0x1010101, v32                          // 0000001552B0: 364040FF 01010101
	v_mul_lo_u32 v27, 0xff, v27                                // 0000001552B8: D72C001B 000236FF 000000FF
	v_and_b32_e32 v36, 0x7f7f7f7f, v31                         // 0000001552C4: 36483EFF 7F7F7F7F
	v_add_nc_u32_e32 v29, 0x7f7f7f7f, v29                      // 0000001552CC: 4A3A3AFF 7F7F7F7F
	v_lshrrev_b32_e32 v33, 7, v33                              // 0000001552D4: 32424287
	v_and_b32_e32 v28, 0x1010101, v28                          // 0000001552D8: 363838FF 01010101
	v_mul_lo_u32 v32, 0xff, v32                                // 0000001552E0: D72C0020 000240FF 000000FF
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_3) | instid1(VALU_DEP_4)// 0000001552EC: BF870244
	v_lshrrev_b32_e32 v29, 7, v29                              // 0000001552F0: 323A3A87
	v_and_b32_e32 v37, 0x7f7f7f7f, v27                         // 0000001552F4: 364A36FF 7F7F7F7F
	v_and_b32_e32 v33, 0x1010101, v33                          // 0000001552FC: 364242FF 01010101
	v_mul_lo_u32 v28, 0xff, v28                                // 000000155304: D72C001C 000238FF 000000FF
	v_and_b32_e32 v29, 0x1010101, v29                          // 000000155310: 363A3AFF 01010101
	v_and_b32_e32 v38, 0x7f7f7f7f, v32                         // 000000155318: 364C40FF 7F7F7F7F
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000155320: BF870194
	v_mul_lo_u32 v33, 0xff, v33                                // 000000155324: D72C0021 000242FF 000000FF
	v_mul_lo_u32 v29, 0xff, v29                                // 000000155330: D72C001D 00023AFF 000000FF
	v_and_b32_e32 v39, 0x7f7f7f7f, v28                         // 00000015533C: 364E38FF 7F7F7F7F
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000155344: BF870193
	v_and_b32_e32 v40, 0x7f7f7f7f, v33                         // 000000155348: 365042FF 7F7F7F7F
	v_and_b32_e32 v41, 0x7f7f7f7f, v29                         // 000000155350: 36523AFF 7F7F7F7F
	s_waitcnt vmcnt(8)                                         // 000000155358: BF8923F7
	v_xor_b32_e32 v30, v30, v16                                // 00000015535C: 3A3C211E
	s_waitcnt vmcnt(7)                                         // 000000155360: BF891FF7
	v_xor_b32_e32 v26, v26, v17                                // 000000155364: 3A34231A
	v_and_b32_e32 v16, 0x80808080, v16                         // 000000155368: 362020FF 80808080
	s_waitcnt vmcnt(6)                                         // 000000155370: BF891BF7
	v_xor_b32_e32 v31, v31, v21                                // 000000155374: 3A3E2B1F
	v_and_b32_e32 v17, 0x80808080, v17                         // 000000155378: 362222FF 80808080
	v_or_b32_e32 v30, 0x80808080, v30                          // 000000155380: 383C3CFF 80808080
	v_or_b32_e32 v26, 0x80808080, v26                          // 000000155388: 383434FF 80808080
	s_waitcnt vmcnt(5)                                         // 000000155390: BF8917F7
	v_xor_b32_e32 v27, v27, v18                                // 000000155394: 3A36251B
	v_or_b32_e32 v31, 0x80808080, v31                          // 000000155398: 383E3EFF 80808080
	v_and_b32_e32 v21, 0x80808080, v21                         // 0000001553A0: 362A2AFF 80808080
	v_sub_nc_u32_e32 v30, v30, v34                             // 0000001553A8: 4C3C451E
	v_sub_nc_u32_e32 v26, v26, v35                             // 0000001553AC: 4C34471A
	s_waitcnt vmcnt(4)                                         // 0000001553B0: BF8913F7
	v_xor_b32_e32 v32, v32, v22                                // 0000001553B4: 3A402D20
	v_or_b32_e32 v27, 0x80808080, v27                          // 0000001553B8: 383636FF 80808080
	v_and_b32_e32 v18, 0x80808080, v18                         // 0000001553C0: 362424FF 80808080
	v_xor3_b32 v16, v16, v30, 0x80808080                       // 0000001553C8: D6400010 03FE3D10 80808080
	v_sub_nc_u32_e32 v30, v31, v36                             // 0000001553D4: 4C3C491F
	v_xor3_b32 v17, v17, v26, 0x80808080                       // 0000001553D8: D6400011 03FE3511 80808080
	s_waitcnt vmcnt(3)                                         // 0000001553E4: BF890FF7
	v_xor_b32_e32 v28, v28, v23                                // 0000001553E8: 3A382F1C
	v_sub_nc_u32_e32 v26, v27, v37                             // 0000001553EC: 4C344B1B
	v_dot4_i32_iu8 v9, v16, v9, 0 neg_lo:[1,1,0]               // 0000001553F0: CC164009 7A021310
	v_or_b32_e32 v16, 0x80808080, v32                          // 0000001553F8: 382040FF 80808080
	v_xor3_b32 v21, v21, v30, 0x80808080                       // 000000155400: D6400015 03FE3D15 80808080
	v_and_b32_e32 v22, 0x80808080, v22                         // 00000015540C: 362C2CFF 80808080
	s_waitcnt vmcnt(2)                                         // 000000155414: BF890BF7
	v_xor_b32_e32 v33, v24, v33                                // 000000155418: 3A424318
	v_dot4_i32_iu8 v9, v17, v10, v9 neg_lo:[1,1,0]             // 00000015541C: CC164009 7C261511
	v_or_b32_e32 v10, 0x80808080, v28                          // 000000155424: 381438FF 80808080
	v_sub_nc_u32_e32 v16, v16, v38                             // 00000015542C: 4C204D10
	v_xor3_b32 v17, v18, v26, 0x80808080                       // 000000155430: D6400011 03FE3512 80808080
	v_and_b32_e32 v23, 0x80808080, v23                         // 00000015543C: 362E2EFF 80808080
	v_dot4_i32_iu8 v9, v21, v11, v9 neg_lo:[1,1,0]             // 000000155444: CC164009 7C261715
	s_waitcnt vmcnt(1)                                         // 00000015544C: BF8907F7
	v_xor_b32_e32 v29, v19, v29                                // 000000155450: 3A3A3B13
	v_or_b32_e32 v11, 0x80808080, v33                          // 000000155454: 381642FF 80808080
	v_sub_nc_u32_e32 v10, v10, v39                             // 00000015545C: 4C144F0A
	v_xor3_b32 v16, v22, v16, 0x80808080                       // 000000155460: D6400010 03FE2116 80808080
	v_dot4_i32_iu8 v9, v17, v12, v9 neg_lo:[1,1,0]             // 00000015546C: CC164009 7C261911
	v_and_b32_e32 v24, 0x80808080, v24                         // 000000155474: 363030FF 80808080
	v_or_b32_e32 v12, 0x80808080, v29                          // 00000015547C: 38183AFF 80808080
	v_sub_nc_u32_e32 v11, v11, v40                             // 000000155484: 4C16510B
	v_xor3_b32 v10, v23, v10, 0x80808080                       // 000000155488: D640000A 03FE1517 80808080
	v_dot4_i32_iu8 v9, v16, v13, v9 neg_lo:[1,1,0]             // 000000155494: CC164009 7C261B10
	v_and_b32_e32 v13, 0x80808080, v19                         // 00000015549C: 361A26FF 80808080
	v_sub_nc_u32_e32 v12, v12, v41                             // 0000001554A4: 4C18530C
	v_xor3_b32 v11, v24, v11, 0x80808080                       // 0000001554A8: D640000B 03FE1718 80808080
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_3)// 0000001554B4: BF870194
	v_dot4_i32_iu8 v9, v10, v14, v9 neg_lo:[1,1,0]             // 0000001554B8: CC164009 7C261D0A
	v_xor3_b32 v10, v13, v12, 0x80808080                       // 0000001554C0: D640000A 03FE190D 80808080
	v_lshrrev_b32_e32 v13, 28, v20                             // 0000001554CC: 321A289C
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 0000001554D0: BF8700A3
	v_dot4_i32_iu8 v9, v11, v15, v9 neg_lo:[1,1,0]             // 0000001554D4: CC164009 7C261F0B
	s_waitcnt vmcnt(0)                                         // 0000001554DC: BF8903F7
	v_dot4_i32_iu8 v12, v10, v25, v9 neg_lo:[1,1,0]            // 0000001554E0: CC16400C 7C26330A
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001554E8: BF870091
	v_lshrrev_b32_e32 v9, 31, v12                              // 0000001554EC: 3212189F
	v_add_nc_u32_e32 v9, v12, v9                               // 0000001554F0: 4A12130C
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001554F4: BF870091
	v_ashrrev_i32_e32 v9, 1, v9                                // 0000001554F8: 34121281
	v_mad_u64_u32 v[10:11], null, v12, v13, v[9:10]            // 0000001554FC: D6FE7C0A 04261B0C
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000155504: BF870091
	v_lshrrev_b32_e32 v9, 31, v10                              // 000000155508: 3212149F
	v_add_nc_u32_e32 v9, v10, v9                               // 00000015550C: 4A12130A
	v_cvt_f32_f16_e32 v10, v8.l                                // 000000155510: 7E141708
	v_cvt_f32_f16_e32 v8, v8.h                                 // 000000155514: 7E101788
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000155518: BF870113
	v_ashrrev_i32_e32 v9, 1, v9                                // 00000015551C: 34121281
	v_mul_f32_e32 v8, v8, v10                                  // 000000155520: 10101508
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000155524: BF870092
	v_cvt_f32_i32_e32 v9, v9                                   // 000000155528: 7E120B09
	v_fmac_f32_e32 v4, v8, v9                                  // 00000015552C: 56081308
	s_and_not1_b32 exec_lo, exec_lo, s11                       // 000000155530: 917E0B7E
	s_cbranch_execnz 65185                                     // 000000155534: BFA6FEA1 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1bc>
	s_or_b32 exec_lo, exec_lo, s11                             // 000000155538: 8C7E0B7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000015553C: BF870009
	s_or_b32 exec_lo, exec_lo, s5                              // 000000155540: 8C7E057E
	s_waitcnt lgkmcnt(0)                                       // 000000155544: BF89FC07
	buffer_gl0_inv                                             // 000000155548: E0AC0000 00000000
	s_mov_b32 s3, exec_lo                                      // 000000155550: BE83007E
	v_cmpx_eq_u32_e32 0, v3                                    // 000000155554: 7D940680
	s_cbranch_execz 65                                         // 000000155558: BFA50041 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x860>
	v_mbcnt_lo_u32_b32 v0, -1, 0                               // 00000015555C: D71F0000 000100C1
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000155564: BF870121
	v_xor_b32_e32 v1, 16, v0                                   // 000000155568: 3A020090
	v_xor_b32_e32 v3, 8, v0                                    // 00000015556C: 3A060088
	v_cmp_gt_i32_e32 vcc_lo, 32, v1                            // 000000155570: 7C8802A0
	v_cndmask_b32_e32 v1, v0, v1, vcc_lo                       // 000000155574: 02020300
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000155578: BF870113
	v_cmp_gt_i32_e32 vcc_lo, 32, v3                            // 00000015557C: 7C8806A0
	v_lshlrev_b32_e32 v1, 2, v1                                // 000000155580: 30020282
	v_cndmask_b32_e32 v3, v0, v3, vcc_lo                       // 000000155584: 02060700
	ds_bpermute_b32 v1, v1, v4                                 // 000000155588: DACC0000 01000401
	v_lshlrev_b32_e32 v3, 2, v3                                // 000000155590: 30060682
	s_waitcnt lgkmcnt(0)                                       // 000000155594: BF89FC07
	v_add_f32_e32 v1, v4, v1                                   // 000000155598: 06020304
	v_xor_b32_e32 v4, 4, v0                                    // 00000015559C: 3A080084
	ds_bpermute_b32 v3, v3, v1                                 // 0000001555A0: DACC0000 03000103
	v_cmp_gt_i32_e32 vcc_lo, 32, v4                            // 0000001555A8: 7C8808A0
	v_cndmask_b32_e32 v4, v0, v4, vcc_lo                       // 0000001555AC: 02080900
	s_waitcnt lgkmcnt(0)                                       // 0000001555B0: BF89FC07
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 0000001555B4: BF8700B1
	v_dual_add_f32 v1, v1, v3 :: v_dual_lshlrev_b32 v4, 2, v4  // 0000001555B8: C9220701 01040882
	ds_bpermute_b32 v3, v4, v1                                 // 0000001555C0: DACC0000 03000104
	v_xor_b32_e32 v4, 2, v0                                    // 0000001555C8: 3A080082
	v_cmp_gt_i32_e32 vcc_lo, 32, v4                            // 0000001555CC: 7C8808A0
	v_cndmask_b32_e32 v4, v0, v4, vcc_lo                       // 0000001555D0: 02080900
	s_waitcnt lgkmcnt(0)                                       // 0000001555D4: BF89FC07
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 0000001555D8: BF8700B1
	v_dual_add_f32 v1, v1, v3 :: v_dual_lshlrev_b32 v4, 2, v4  // 0000001555DC: C9220701 01040882
	ds_bpermute_b32 v3, v4, v1                                 // 0000001555E4: DACC0000 03000104
	v_xor_b32_e32 v4, 1, v0                                    // 0000001555EC: 3A080081
	v_cmp_gt_i32_e32 vcc_lo, 32, v4                            // 0000001555F0: 7C8808A0
	v_cndmask_b32_e32 v0, v0, v4, vcc_lo                       // 0000001555F4: 02000900
	v_cmp_eq_u32_e32 vcc_lo, 0, v2                             // 0000001555F8: 7C940480
	s_delay_alu instid0(VALU_DEP_2)                            // 0000001555FC: BF870002
	v_lshlrev_b32_e32 v4, 2, v0                                // 000000155600: 30080082
	s_waitcnt lgkmcnt(0)                                       // 000000155604: BF89FC07
	v_add_f32_e32 v0, v1, v3                                   // 000000155608: 06000701
	ds_bpermute_b32 v1, v4, v0                                 // 00000015560C: DACC0000 01000004
	s_and_b32 exec_lo, exec_lo, vcc_lo                         // 000000155614: 8B7E6A7E
	s_cbranch_execz 17                                         // 000000155618: BFA50011 <_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x860>
	s_load_b64 s[0:1], s[0:1], 0x68                            // 00000015561C: F4040000 F8000068
	s_mul_i32 s3, s10, s6                                      // 000000155624: 9603060A
	s_waitcnt lgkmcnt(0)                                       // 000000155628: BF89FC07
	v_dual_add_f32 v0, v0, v1 :: v_dual_mov_b32 v1, 0          // 00000015562C: C9100300 00000080
	s_add_i32 s2, s3, s2                                       // 000000155634: 81020203
	s_mul_i32 s3, s14, s4                                      // 000000155638: 9603040E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000015563C: BF8704A9
	s_add_i32 s2, s2, s3                                       // 000000155640: 81020302
	s_mov_b32 s3, 0                                            // 000000155644: BE830080
	s_lshl_b64 s[2:3], s[2:3], 2                               // 000000155648: 84828202
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000015564C: BF870009
	s_add_u32 s0, s0, s2                                       // 000000155650: 80000200
	s_addc_u32 s1, s1, s3                                      // 000000155654: 82010301
	global_store_b32 v1, v0, s[0:1]                            // 000000155658: DC6A0000 00000001
	s_endpgm                                                   // 000000155660: BFB00000
		...
