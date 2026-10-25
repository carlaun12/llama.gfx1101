
build-hip-baseline/bin/libggml-hip.so.36.hipv4-amdgcn-amd-amdhsa--gfx1101:	file format elf64-amdgpu

Disassembly of section .text:

0000000000187400 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj>:
	s_clause 0x1                                               // 000000187400: BF850001
	s_load_b64 s[8:9], s[0:1], 0x10                            // 000000187404: F4040200 F8000010
	s_load_b128 s[16:19], s[0:1], 0x70                         // 00000018740C: F4080400 F8000070
	s_mov_b32 s6, s3                                           // 000000187414: BE860003
	s_waitcnt lgkmcnt(0)                                       // 000000187418: BF89FC07
	s_cmp_lg_u64 s[8:9], 0                                     // 00000018741C: BF118008
	s_cselect_b32 s5, -1, 0                                    // 000000187420: 980580C1
	s_cmp_eq_u64 s[8:9], 0                                     // 000000187424: BF108008
	s_cbranch_scc1 32                                          // 000000187428: BFA20020 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xac>
	s_mov_b32 s7, 0                                            // 00000018742C: BE870080
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000187430: BF870499
	s_lshl_b64 s[10:11], s[6:7], 2                             // 000000187434: 848A8206
	s_add_u32 s8, s8, s10                                      // 000000187438: 80080A08
	s_addc_u32 s9, s9, s11                                     // 00000018743C: 82090B09
	s_load_b32 s3, s[8:9], null                                // 000000187440: F40000C4 F8000000
	s_clause 0x1                                               // 000000187448: BF850001
	s_load_b128 s[8:11], s[0:1], 0x98                          // 00000018744C: F4080200 F8000098
	s_load_b32 s20, s[0:1], 0x80                               // 000000187454: F4000500 F8000080
	s_cbranch_execnz 7                                         // 00000018745C: BFA60007 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x7c>
	s_load_b64 s[12:13], s[0:1], 0x8c                          // 000000187460: F4040300 F800008C
	s_waitcnt lgkmcnt(0)                                       // 000000187468: BF89FC07
	s_mul_hi_u32 s3, s12, s6                                   // 00000018746C: 9683060C
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000187470: BF870499
	s_add_i32 s3, s6, s3                                       // 000000187474: 81030306
	s_lshr_b32 s3, s3, s13                                     // 000000187478: 85030D03
	s_load_b32 s21, s[0:1], 0xa8                               // 00000018747C: F4000540 F80000A8
	s_and_not1_b32 vcc_lo, exec_lo, s5                         // 000000187484: 916A057E
	s_cbranch_vccnz 14                                         // 000000187488: BFA4000E <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xc4>
	s_mul_hi_u32 s5, s17, s6                                   // 00000018748C: 96850611
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000187490: BF870499
	s_add_i32 s5, s6, s5                                       // 000000187494: 81050506
	s_lshr_b32 s5, s5, s18                                     // 000000187498: 85051205
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000018749C: BF870499
	s_mul_i32 s5, s5, s19                                      // 0000001874A0: 96051305
	s_sub_i32 s17, s6, s5                                      // 0000001874A4: 81910506
	s_branch 7                                                 // 0000001874A8: BFA00007 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0xc8>
	s_clause 0x1                                               // 0000001874AC: BF850001
	s_load_b128 s[8:11], s[0:1], 0x98                          // 0000001874B0: F4080200 F8000098
	s_load_b32 s20, s[0:1], 0x80                               // 0000001874B8: F4000500 F8000080
	s_branch 65511                                             // 0000001874C0: BFA0FFE7 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x60>
	s_mov_b32 s17, s6                                          // 0000001874C4: BE910006
	s_load_b128 s[12:15], s[0:1], 0xb0                         // 0000001874C8: F4080300 F80000B0
	v_bfe_u32 v3, v0, 10, 10                                   // 0000001874D0: D6100003 02291500
	v_dual_mov_b32 v5, 0 :: v_dual_and_b32 v2, 0x3ff, v0       // 0000001874D8: CA240080 050200FF 000003FF
	s_lshr_b32 s7, s16, 8                                      // 0000001874E4: 85078810
	s_mov_b32 s5, exec_lo                                      // 0000001874E8: BE85007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000001874EC: BF870091
	v_lshl_or_b32 v0, v3, 5, v2                                // 0000001874F0: D6560000 04090B03
	v_lshrrev_b32_e32 v4, 3, v0                                // 0000001874F8: 32080083
	s_delay_alu instid0(VALU_DEP_1)                            // 0000001874FC: BF870001
	v_cmpx_gt_u32_e64 s7, v4                                   // 000000187500: D4CC007E 00020807
	s_cbranch_execz 454                                        // 000000187508: BFA501C6 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x824>
	v_lshrrev_b32_e32 v5, 3, v0                                // 00000018750C: 320A0083
	s_waitcnt lgkmcnt(0)                                       // 000000187510: BF89FC07
	s_mul_i32 s9, s17, s9                                      // 000000187514: 96090911
	v_and_b32_e32 v6, 7, v2                                    // 000000187518: 360C0487
	s_mul_hi_u32 s17, s9, 36                                   // 00000018751C: 9691A409
	s_mul_i32 s16, s9, 36                                      // 000000187520: 9610A409
	s_mul_i32 s9, s13, s4                                      // 000000187524: 9609040D
	v_mad_u64_u32 v[0:1], null, 0x120, v5, s[16:17]            // 000000187528: D6FE7C00 00420AFF 00000120
	s_load_b128 s[16:19], s[0:1], null                         // 000000187534: F4080400 F8000000
	v_lshlrev_b32_e32 v9, 1, v2                                // 00000018753C: 30120481
	v_mov_b32_e32 v5, 0                                        // 000000187540: 7E0A0280
	s_mul_i32 s3, s3, s8                                       // 000000187544: 96030803
	s_mul_i32 s20, s20, s2                                     // 000000187548: 96140214
	v_mad_u64_u32 v[7:8], null, s9, 36, v[0:1]                 // 00000018754C: D6FE7C07 04014809
	v_and_b32_e32 v10, 14, v9                                  // 000000187554: 3614128E
	s_mul_hi_u32 s9, s11, s4                                   // 000000187558: 9689040B
	s_mov_b32 s11, 0                                           // 00000018755C: BE8B0080
	s_add_i32 s9, s4, s9                                       // 000000187560: 81090904
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000187564: BF870191
	v_lshlrev_b32_e32 v11, 1, v10                              // 000000187568: 30161481
	v_mad_u64_u32 v[0:1], null, v6, 36, v[7:8]                 // 00000018756C: D6FE7C00 041D4906
	s_lshr_b32 s8, s9, s21                                     // 000000187574: 85081509
	v_bfe_u32 v7, v9, 2, 2                                     // 000000187578: D6100007 02090509
	s_mul_i32 s8, s8, s12                                      // 000000187580: 96080C08
	v_and_b32_e32 v8, 4, v11                                   // 000000187584: 36101684
	v_lshlrev_b32_e32 v9, 1, v11                               // 000000187588: 30121681
	v_lshlrev_b32_e32 v10, 1, v10                              // 00000018758C: 30141481
	s_waitcnt lgkmcnt(0)                                       // 000000187590: BF89FC07
	v_add_co_u32 v0, vcc_lo, s18, v0                           // 000000187594: D7006A00 00020012
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000018759C: BF8700B1
	v_add_co_ci_u32_e64 v1, null, s19, v1, vcc_lo              // 0000001875A0: D5207C01 01AA0213
	s_add_i32 s8, s8, s20                                      // 0000001875A8: 81081408
	v_add_co_u32 v0, vcc_lo, v0, 32                            // 0000001875AC: D7006A00 00014100
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo                // 0000001875B4: D5207C01 01AA0280
	s_add_i32 s12, s3, s8                                      // 0000001875BC: 810C0803
	s_delay_alu instid0(SALU_CYCLE_1)                          // 0000001875C0: BF870009
	v_add_nc_u32_e32 v11, s12, v4                              // 0000001875C4: 4A16080C
	s_getpc_b64 s[8:9]                                         // 0000001875C8: BE884700
	s_add_u32 s8, s8, 0xfff1b934                               // 0000001875CC: 8008FF08 FFF1B934
	s_addc_u32 s9, s9, -1                                      // 0000001875D4: 8209FF09 FFFFFFFF
	v_add_nc_u32_e32 v4, 4, v4                                 // 0000001875DC: 4A080884
	v_mad_i64_i32 v[19:20], null, 0x6e, v11, s[16:17]          // 0000001875E0: D6FF7C13 004216FF 0000006E
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 0000001875EC: BF8700B2
	v_cmp_le_u32_e64 s3, s7, v4                                // 0000001875F0: D44B0003 00020807
	s_or_b32 s11, s3, s11                                      // 0000001875F8: 8C0B0B03
	v_add_co_u32 v11, vcc_lo, v19, v9                          // 0000001875FC: D7006A0B 00021313
	v_add_co_ci_u32_e64 v12, null, 0, v20, vcc_lo              // 000000187604: D5207C0C 01AA2880
	v_add_co_u32 v13, vcc_lo, v19, v6                          // 00000018760C: D7006A0D 00020D13
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_1)// 000000187614: BF8700D1
	v_add_co_ci_u32_e64 v14, null, 0, v20, vcc_lo              // 000000187618: D5207C0E 01AA2880
	s_clause 0x1                                               // 000000187620: BF850001
	global_load_b64 v[21:22], v[11:12], off offset:2           // 000000187624: DC560002 157C000B
	global_load_u8 v27, v[13:14], off offset:66                // 00000018762C: DC420042 1B7C000D
	v_add_co_u32 v23, vcc_lo, v19, v10                         // 000000187634: D7006A17 00021513
	v_add_co_ci_u32_e64 v24, null, 0, v20, vcc_lo              // 00000018763C: D5207C18 01AA2880
	v_add_co_u32 v25, vcc_lo, v19, v7                          // 000000187644: D7006A19 00020F13
	s_delay_alu instid0(VALU_DEP_1)                            // 00000018764C: BF870001
	v_add_co_ci_u32_e64 v26, null, 0, v20, vcc_lo              // 000000187650: D5207C1A 01AA2880
	s_clause 0x1                                               // 000000187658: BF850001
	global_load_b128 v[11:14], v[0:1], off offset:-32          // 00000018765C: DC5E1FE0 0B7C0000
	global_load_b128 v[15:18], v[0:1], off offset:-16          // 000000187664: DC5E1FF0 0F7C0000
	s_clause 0x2                                               // 00000018766C: BF850002
	global_load_b32 v23, v[23:24], off offset:74               // 000000187670: DC52004A 177C0017
	global_load_u8 v24, v[25:26], off offset:106               // 000000187678: DC42006A 187C0019
	global_load_d16_hi_b16 v11, v[19:20], off                  // 000000187680: DC8E0000 0B7C0013
	s_waitcnt vmcnt(6)                                         // 000000187688: BF891BF7
	v_and_b32_e32 v19, 0xff, v21                               // 00000018768C: 36262AFF 000000FF
	s_waitcnt vmcnt(5)                                         // 000000187694: BF8917F7
	v_lshlrev_b32_e32 v20, 8, v27                              // 000000187698: 30283688
	v_bfe_u32 v25, v21, 8, 8                                   // 00000018769C: D6100019 02211115
	v_lshlrev_b32_e32 v26, 7, v27                              // 0000001876A4: 30343687
	v_bfe_u32 v28, v21, 16, 8                                  // 0000001876A8: D610001C 02212115
	v_lshlrev_b32_e32 v29, 6, v27                              // 0000001876B0: 303A3686
	v_lshrrev_b32_e32 v21, 24, v21                             // 0000001876B4: 322A2A98
	v_lshlrev_b32_e32 v30, 5, v27                              // 0000001876B8: 303C3685
	v_and_b32_e32 v31, 0xff, v22                               // 0000001876BC: 363E2CFF 000000FF
	v_lshlrev_b32_e32 v32, 4, v27                              // 0000001876C4: 30403684
	v_bfe_u32 v33, v22, 8, 8                                   // 0000001876C8: D6100021 02211116
	v_lshlrev_b32_e32 v34, 3, v27                              // 0000001876D0: 30443683
	v_bfe_u32 v35, v22, 16, 8                                  // 0000001876D4: D6100023 02212116
	v_lshlrev_b32_e32 v36, 2, v27                              // 0000001876DC: 30483682
	v_lshrrev_b32_e32 v22, 24, v22                             // 0000001876E0: 322C2C98
	v_lshlrev_b32_e32 v27, 1, v27                              // 0000001876E4: 30363681
	v_and_or_b32 v19, 0x100, v20, v19                          // 0000001876E8: D6570013 044E28FF 00000100
	v_and_or_b32 v20, 0x100, v26, v25                          // 0000001876F4: D6570014 046634FF 00000100
	v_and_or_b32 v25, 0x100, v29, v28                          // 000000187700: D6570019 04723AFF 00000100
	v_and_or_b32 v21, 0x100, v30, v21                          // 00000018770C: D6570015 04563CFF 00000100
	v_and_or_b32 v26, 0x100, v32, v31                          // 000000187718: D657001A 047E40FF 00000100
	v_and_or_b32 v28, 0x100, v34, v33                          // 000000187724: D657001C 048644FF 00000100
	v_and_or_b32 v29, 0x100, v36, v35                          // 000000187730: D657001D 048E48FF 00000100
	v_and_or_b32 v22, 0x100, v27, v22                          // 00000018773C: D6570016 045A36FF 00000100
	v_lshlrev_b32_e32 v19, 2, v19                              // 000000187748: 30262682
	v_lshlrev_b32_e32 v20, 2, v20                              // 00000018774C: 30282882
	v_lshlrev_b32_e32 v25, 2, v25                              // 000000187750: 30323282
	v_lshlrev_b32_e32 v21, 2, v21                              // 000000187754: 302A2A82
	v_lshlrev_b32_e32 v26, 2, v26                              // 000000187758: 30343482
	v_lshlrev_b32_e32 v27, 2, v28                              // 00000018775C: 30363882
	v_lshlrev_b32_e32 v28, 2, v29                              // 000000187760: 30383A82
	v_lshlrev_b32_e32 v22, 2, v22                              // 000000187764: 302C2C82
	s_clause 0x7                                               // 000000187768: BF850007
	global_load_b32 v19, v19, s[8:9]                           // 00000018776C: DC520000 13080013
	global_load_b32 v20, v20, s[8:9]                           // 000000187774: DC520000 14080014
	global_load_b32 v25, v25, s[8:9]                           // 00000018777C: DC520000 19080019
	global_load_b32 v21, v21, s[8:9]                           // 000000187784: DC520000 15080015
	global_load_b32 v26, v26, s[8:9]                           // 00000018778C: DC520000 1A08001A
	global_load_b32 v27, v27, s[8:9]                           // 000000187794: DC520000 1B08001B
	global_load_b32 v28, v28, s[8:9]                           // 00000018779C: DC520000 1C08001C
	global_load_b32 v22, v22, s[8:9]                           // 0000001877A4: DC520000 16080016
	global_load_b32 v29, v[0:1], off                           // 0000001877AC: DC520000 1D7C0000
	s_waitcnt vmcnt(11)                                        // 0000001877B4: BF892FF7
	v_lshlrev_b32_e32 v31, 21, v23                             // 0000001877B8: 303E2E95
	v_lshlrev_b32_e32 v30, 7, v23                              // 0000001877BC: 303C2E87
	v_lshlrev_b32_e32 v33, 17, v23                             // 0000001877C0: 30422E91
	v_lshrrev_b32_e32 v36, 5, v23                              // 0000001877C4: 32482E85
	v_lshlrev_b32_e32 v32, 3, v23                              // 0000001877C8: 30402E83
	v_and_b32_e32 v31, 0x1800000, v31                          // 0000001877CC: 363E3EFF 01800000
	v_lshrrev_b32_e32 v34, 1, v23                              // 0000001877D4: 32442E81
	v_lshlrev_b32_e32 v37, 9, v23                              // 0000001877D8: 304A2E89
	v_lshrrev_b32_e32 v38, 9, v23                              // 0000001877DC: 324C2E89
	v_and_b32_e32 v33, 0x1800000, v33                          // 0000001877E0: 364242FF 01800000
	v_and_b32_e32 v36, 0x180, v36                              // 0000001877E8: 364848FF 00000180
	v_and_or_b32 v30, 0x180, v30, v31                          // 0000001877F0: D657001E 047E3CFF 00000180
	v_lshlrev_b32_e32 v35, 13, v23                             // 0000001877FC: 30462E8D
	v_lshlrev_b32_e32 v39, 5, v23                              // 000000187800: 304E2E85
	v_and_b32_e32 v34, 0x180, v34                              // 000000187804: 364444FF 00000180
	v_and_b32_e32 v38, 0x180, v38                              // 00000018780C: 364C4CFF 00000180
	v_and_or_b32 v31, 0x180, v32, v33                          // 000000187814: D657001F 048640FF 00000180
	v_and_or_b32 v33, 0x1800000, v37, v36                      // 000000187820: D6570021 04924AFF 01800000
	v_and_b32_e32 v37, 0x1000100, v30                          // 00000018782C: 364A3CFF 01000100
	v_lshrrev_b32_e32 v40, 13, v23                             // 000000187834: 32502E8D
	v_and_or_b32 v32, 0x1800000, v35, v34                      // 000000187838: D6570020 048A46FF 01800000
	v_and_or_b32 v34, 0x1800000, v39, v38                      // 000000187844: D6570022 049A4EFF 01800000
	v_and_b32_e32 v38, 0x1000100, v31                          // 000000187850: 364C3EFF 01000100
	v_add_nc_u32_e32 v37, 0x7f7f7f7f, v37                      // 000000187858: 4A4A4AFF 7F7F7F7F
	v_lshlrev_b32_e32 v41, 1, v23                              // 000000187860: 30522E81
	v_and_b32_e32 v40, 0x180, v40                              // 000000187864: 365050FF 00000180
	v_and_b32_e32 v39, 0x1000100, v32                          // 00000018786C: 364E40FF 01000100
	v_add_nc_u32_e32 v38, 0x7f7f7f7f, v38                      // 000000187874: 4A4C4CFF 7F7F7F7F
	v_or_b32_e32 v30, v37, v30                                 // 00000018787C: 383C3D25
	v_lshrrev_b32_e32 v43, 3, v23                              // 000000187880: 32562E83
	v_and_or_b32 v35, 0x1800000, v41, v40                      // 000000187884: D6570023 04A252FF 01800000
	v_and_b32_e32 v40, 0x1000100, v33                          // 000000187890: 365042FF 01000100
	v_add_nc_u32_e32 v39, 0x7f7f7f7f, v39                      // 000000187898: 4A4E4EFF 7F7F7F7F
	v_or_b32_e32 v31, v38, v31                                 // 0000001878A0: 383E3F26
	v_lshrrev_b32_e32 v30, 7, v30                              // 0000001878A4: 323C3C87
	v_lshrrev_b32_e32 v42, 17, v23                             // 0000001878A8: 32542E91
	v_lshrrev_b32_e32 v44, 21, v23                             // 0000001878AC: 32582E95
	v_lshrrev_b32_e32 v23, 7, v23                              // 0000001878B0: 322E2E87
	v_and_b32_e32 v43, 0x1800000, v43                          // 0000001878B4: 365656FF 01800000
	v_and_b32_e32 v41, 0x1000100, v34                          // 0000001878BC: 365244FF 01000100
	v_add_nc_u32_e32 v40, 0x7f7f7f7f, v40                      // 0000001878C4: 4A5050FF 7F7F7F7F
	v_or_b32_e32 v32, v39, v32                                 // 0000001878CC: 38404127
	v_lshrrev_b32_e32 v31, 7, v31                              // 0000001878D0: 323E3E87
	v_and_b32_e32 v30, 0x1010101, v30                          // 0000001878D4: 363C3CFF 01010101
	v_and_b32_e32 v23, 0x1800000, v23                          // 0000001878DC: 362E2EFF 01800000
	v_and_or_b32 v36, 0x180, v42, v43                          // 0000001878E4: D6570024 04AE54FF 00000180
	v_and_b32_e32 v42, 0x1000100, v35                          // 0000001878F0: 365446FF 01000100
	v_add_nc_u32_e32 v41, 0x7f7f7f7f, v41                      // 0000001878F8: 4A5252FF 7F7F7F7F
	v_or_b32_e32 v33, v40, v33                                 // 000000187900: 38424328
	v_lshrrev_b32_e32 v32, 7, v32                              // 000000187904: 32404087
	v_and_b32_e32 v31, 0x1010101, v31                          // 000000187908: 363E3EFF 01010101
	v_mul_lo_u32 v30, 0xff, v30                                // 000000187910: D72C001E 00023CFF 000000FF
	v_and_or_b32 v23, 0x180, v44, v23                          // 00000018791C: D6570017 045E58FF 00000180
	v_and_b32_e32 v43, 0x1000100, v36                          // 000000187928: 365648FF 01000100
	v_add_nc_u32_e32 v42, 0x7f7f7f7f, v42                      // 000000187930: 4A5454FF 7F7F7F7F
	v_or_b32_e32 v34, v41, v34                                 // 000000187938: 38444529
	v_lshrrev_b32_e32 v33, 7, v33                              // 00000018793C: 32424287
	v_and_b32_e32 v32, 0x1010101, v32                          // 000000187940: 364040FF 01010101
	v_mul_lo_u32 v31, 0xff, v31                                // 000000187948: D72C001F 00023EFF 000000FF
	v_and_b32_e32 v37, 0x7f7f7f7f, v30                         // 000000187954: 364A3CFF 7F7F7F7F
	v_and_b32_e32 v44, 0x1000100, v23                          // 00000018795C: 36582EFF 01000100
	v_add_nc_u32_e32 v43, 0x7f7f7f7f, v43                      // 000000187964: 4A5656FF 7F7F7F7F
	v_or_b32_e32 v35, v42, v35                                 // 00000018796C: 3846472A
	v_lshrrev_b32_e32 v34, 7, v34                              // 000000187970: 32444487
	v_and_b32_e32 v33, 0x1010101, v33                          // 000000187974: 364242FF 01010101
	v_mul_lo_u32 v32, 0xff, v32                                // 00000018797C: D72C0020 000240FF 000000FF
	v_and_b32_e32 v38, 0x7f7f7f7f, v31                         // 000000187988: 364C3EFF 7F7F7F7F
	v_add_nc_u32_e32 v44, 0x7f7f7f7f, v44                      // 000000187990: 4A5858FF 7F7F7F7F
	v_or_b32_e32 v36, v43, v36                                 // 000000187998: 3848492B
	v_lshrrev_b32_e32 v35, 7, v35                              // 00000018799C: 32464687
	v_and_b32_e32 v34, 0x1010101, v34                          // 0000001879A0: 364444FF 01010101
	v_mul_lo_u32 v33, 0xff, v33                                // 0000001879A8: D72C0021 000242FF 000000FF
	v_or_b32_e32 v23, v44, v23                                 // 0000001879B4: 382E2F2C
	v_and_b32_e32 v39, 0x7f7f7f7f, v32                         // 0000001879B8: 364E40FF 7F7F7F7F
	v_lshrrev_b32_e32 v36, 7, v36                              // 0000001879C0: 32484887
	v_and_b32_e32 v35, 0x1010101, v35                          // 0000001879C4: 364646FF 01010101
	v_mul_lo_u32 v34, 0xff, v34                                // 0000001879CC: D72C0022 000244FF 000000FF
	v_lshrrev_b32_e32 v23, 7, v23                              // 0000001879D8: 322E2E87
	s_waitcnt vmcnt(10)                                        // 0000001879DC: BF892BF7
	v_lshrrev_b32_e32 v24, v8, v24                             // 0000001879E0: 32303108
	v_and_b32_e32 v40, 0x7f7f7f7f, v33                         // 0000001879E4: 365042FF 7F7F7F7F
	v_and_b32_e32 v36, 0x1010101, v36                          // 0000001879EC: 364848FF 01010101
	v_mul_lo_u32 v35, 0xff, v35                                // 0000001879F4: D72C0023 000246FF 000000FF
	v_and_b32_e32 v23, 0x1010101, v23                          // 000000187A00: 362E2EFF 01010101
	v_add_co_u32 v0, vcc_lo, 0x480, v0                         // 000000187A08: D7006A00 000200FF 00000480
	v_and_b32_e32 v41, 0x7f7f7f7f, v34                         // 000000187A14: 365244FF 7F7F7F7F
	v_mul_lo_u32 v36, 0xff, v36                                // 000000187A1C: D72C0024 000248FF 000000FF
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_2) | instid1(VALU_DEP_4)// 000000187A28: BF870234
	v_mul_lo_u32 v23, 0xff, v23                                // 000000187A2C: D72C0017 00022EFF 000000FF
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo                // 000000187A38: D5207C01 01AA0280
	v_and_b32_e32 v42, 0x7f7f7f7f, v35                         // 000000187A40: 365446FF 7F7F7F7F
	v_and_b32_e32 v43, 0x7f7f7f7f, v36                         // 000000187A48: 365648FF 7F7F7F7F
	s_delay_alu instid0(VALU_DEP_4)                            // 000000187A50: BF870004
	v_and_b32_e32 v44, 0x7f7f7f7f, v23                         // 000000187A54: 36582EFF 7F7F7F7F
	s_waitcnt vmcnt(8)                                         // 000000187A5C: BF8923F7
	v_xor_b32_e32 v30, v30, v19                                // 000000187A60: 3A3C271E
	s_waitcnt vmcnt(7)                                         // 000000187A64: BF891FF7
	v_xor_b32_e32 v31, v31, v20                                // 000000187A68: 3A3E291F
	v_and_b32_e32 v19, 0x80808080, v19                         // 000000187A6C: 362626FF 80808080
	s_waitcnt vmcnt(6)                                         // 000000187A74: BF891BF7
	v_xor_b32_e32 v32, v32, v25                                // 000000187A78: 3A403320
	v_and_b32_e32 v20, 0x80808080, v20                         // 000000187A7C: 362828FF 80808080
	v_or_b32_e32 v30, 0x80808080, v30                          // 000000187A84: 383C3CFF 80808080
	v_or_b32_e32 v31, 0x80808080, v31                          // 000000187A8C: 383E3EFF 80808080
	s_waitcnt vmcnt(5)                                         // 000000187A94: BF8917F7
	v_xor_b32_e32 v33, v33, v21                                // 000000187A98: 3A422B21
	v_or_b32_e32 v32, 0x80808080, v32                          // 000000187A9C: 384040FF 80808080
	v_and_b32_e32 v25, 0x80808080, v25                         // 000000187AA4: 363232FF 80808080
	v_sub_nc_u32_e32 v30, v30, v37                             // 000000187AAC: 4C3C4B1E
	v_sub_nc_u32_e32 v31, v31, v38                             // 000000187AB0: 4C3E4D1F
	s_waitcnt vmcnt(4)                                         // 000000187AB4: BF8913F7
	v_xor_b32_e32 v34, v34, v26                                // 000000187AB8: 3A443522
	v_sub_nc_u32_e32 v32, v32, v39                             // 000000187ABC: 4C404F20
	v_and_b32_e32 v21, 0x80808080, v21                         // 000000187AC0: 362A2AFF 80808080
	v_xor3_b32 v19, v19, v30, 0x80808080                       // 000000187AC8: D6400013 03FE3D13 80808080
	v_or_b32_e32 v30, 0x80808080, v33                          // 000000187AD4: 383C42FF 80808080
	v_xor3_b32 v20, v20, v31, 0x80808080                       // 000000187ADC: D6400014 03FE3F14 80808080
	s_waitcnt vmcnt(3)                                         // 000000187AE8: BF890FF7
	v_xor_b32_e32 v35, v35, v27                                // 000000187AEC: 3A463723
	v_xor3_b32 v25, v25, v32, 0x80808080                       // 000000187AF0: D6400019 03FE4119 80808080
	v_dot4_i32_iu8 v12, v19, v12, 0 neg_lo:[1,1,0]             // 000000187AFC: CC16400C 7A021913
	v_or_b32_e32 v19, 0x80808080, v34                          // 000000187B04: 382644FF 80808080
	v_sub_nc_u32_e32 v30, v30, v40                             // 000000187B0C: 4C3C511E
	v_and_b32_e32 v26, 0x80808080, v26                         // 000000187B10: 363434FF 80808080
	s_waitcnt vmcnt(2)                                         // 000000187B18: BF890BF7
	v_xor_b32_e32 v36, v28, v36                                // 000000187B1C: 3A48491C
	v_dot4_i32_iu8 v12, v20, v13, v12 neg_lo:[1,1,0]           // 000000187B20: CC16400C 7C321B14
	v_or_b32_e32 v13, 0x80808080, v35                          // 000000187B28: 381A46FF 80808080
	v_sub_nc_u32_e32 v19, v19, v41                             // 000000187B30: 4C265313
	v_xor3_b32 v20, v21, v30, 0x80808080                       // 000000187B34: D6400014 03FE3D15 80808080
	v_and_b32_e32 v27, 0x80808080, v27                         // 000000187B40: 363636FF 80808080
	v_dot4_i32_iu8 v12, v25, v14, v12 neg_lo:[1,1,0]           // 000000187B48: CC16400C 7C321D19
	s_waitcnt vmcnt(1)                                         // 000000187B50: BF8907F7
	v_xor_b32_e32 v23, v22, v23                                // 000000187B54: 3A2E2F16
	v_or_b32_e32 v14, 0x80808080, v36                          // 000000187B58: 381C48FF 80808080
	v_sub_nc_u32_e32 v13, v13, v42                             // 000000187B60: 4C1A550D
	v_xor3_b32 v19, v26, v19, 0x80808080                       // 000000187B64: D6400013 03FE271A 80808080
	v_dot4_i32_iu8 v12, v20, v15, v12 neg_lo:[1,1,0]           // 000000187B70: CC16400C 7C321F14
	v_and_b32_e32 v28, 0x80808080, v28                         // 000000187B78: 363838FF 80808080
	v_or_b32_e32 v15, 0x80808080, v23                          // 000000187B80: 381E2EFF 80808080
	v_sub_nc_u32_e32 v14, v14, v43                             // 000000187B88: 4C1C570E
	v_xor3_b32 v13, v27, v13, 0x80808080                       // 000000187B8C: D640000D 03FE1B1B 80808080
	v_dot4_i32_iu8 v12, v19, v16, v12 neg_lo:[1,1,0]           // 000000187B98: CC16400C 7C322113
	v_and_b32_e32 v16, 0x80808080, v22                         // 000000187BA0: 36202CFF 80808080
	v_sub_nc_u32_e32 v15, v15, v44                             // 000000187BA8: 4C1E590F
	v_xor3_b32 v14, v28, v14, 0x80808080                       // 000000187BAC: D640000E 03FE1D1C 80808080
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_1) | instid1(VALU_DEP_4)// 000000187BB8: BF870224
	v_dot4_i32_iu8 v12, v13, v17, v12 neg_lo:[1,1,0]           // 000000187BBC: CC16400C 7C32230D
	v_lshlrev_b32_e32 v13, 1, v24                              // 000000187BC4: 301A3081
	v_xor3_b32 v15, v16, v15, 0x80808080                       // 000000187BC8: D640000F 03FE1F10 80808080
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000187BD4: BF870193
	v_dot4_i32_iu8 v12, v14, v18, v12 neg_lo:[1,1,0]           // 000000187BD8: CC16400C 7C32250E
	v_and_or_b32 v13, v13, 30, 1                               // 000000187BE0: D657000D 02053D0D
	v_cvt_f32_f16_e32 v14, v11.l                               // 000000187BE8: 7E1C170B
	v_cvt_f32_f16_e32 v11, v11.h                               // 000000187BEC: 7E16178B
	s_waitcnt vmcnt(0)                                         // 000000187BF0: BF8903F7
	v_dot4_i32_iu8 v12, v15, v29, v12 neg_lo:[1,1,0]           // 000000187BF4: CC16400C 7C323B0F
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000187BFC: BF870112
	v_mul_f32_e32 v11, v11, v14                                // 000000187C00: 10161D0B
	v_mul_lo_u32 v12, v13, v12                                 // 000000187C04: D72C000C 0002190D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000187C0C: BF870091
	v_cvt_f32_i32_e32 v12, v12                                 // 000000187C10: 7E180B0C
	v_fmac_f32_e32 v5, v11, v12                                // 000000187C14: 560A190B
	s_and_not1_b32 exec_lo, exec_lo, s11                       // 000000187C18: 917E0B7E
	s_cbranch_execnz 65128                                     // 000000187C1C: BFA6FE68 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x1c0>
	s_or_b32 exec_lo, exec_lo, s11                             // 000000187C20: 8C7E0B7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000187C24: BF870009
	s_or_b32 exec_lo, exec_lo, s5                              // 000000187C28: 8C7E057E
	s_waitcnt lgkmcnt(0)                                       // 000000187C2C: BF89FC07
	buffer_gl0_inv                                             // 000000187C30: E0AC0000 00000000
	s_mov_b32 s3, exec_lo                                      // 000000187C38: BE83007E
	v_cmpx_eq_u32_e32 0, v3                                    // 000000187C3C: 7D940680
	s_cbranch_execz 65                                         // 000000187C40: BFA50041 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x948>
	v_mbcnt_lo_u32_b32 v0, -1, 0                               // 000000187C44: D71F0000 000100C1
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000187C4C: BF8701B1
	v_xor_b32_e32 v1, 16, v0                                   // 000000187C50: 3A020090
	v_xor_b32_e32 v3, 8, v0                                    // 000000187C54: 3A060088
	v_xor_b32_e32 v4, 4, v0                                    // 000000187C58: 3A080084
	v_cmp_gt_i32_e32 vcc_lo, 32, v1                            // 000000187C5C: 7C8802A0
	v_cndmask_b32_e32 v1, v0, v1, vcc_lo                       // 000000187C60: 02020300
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_2) | instid1(VALU_DEP_2)// 000000187C64: BF870134
	v_cmp_gt_i32_e32 vcc_lo, 32, v3                            // 000000187C68: 7C8806A0
	v_cndmask_b32_e32 v3, v0, v3, vcc_lo                       // 000000187C6C: 02060700
	v_cmp_gt_i32_e32 vcc_lo, 32, v4                            // 000000187C70: 7C8808A0
	v_dual_cndmask_b32 v4, v0, v4 :: v_dual_lshlrev_b32 v3, 2, v3// 000000187C74: CA620900 04020682
	s_delay_alu instid0(VALU_DEP_1)                            // 000000187C7C: BF870001
	v_lshlrev_b32_e32 v4, 2, v4                                // 000000187C80: 30080882
	v_lshlrev_b32_e32 v1, 2, v1                                // 000000187C84: 30020282
	ds_bpermute_b32 v1, v1, v5                                 // 000000187C88: DACC0000 01000501
	s_waitcnt lgkmcnt(0)                                       // 000000187C90: BF89FC07
	v_add_f32_e32 v1, v5, v1                                   // 000000187C94: 06020305
	ds_bpermute_b32 v3, v3, v1                                 // 000000187C98: DACC0000 03000103
	s_waitcnt lgkmcnt(0)                                       // 000000187CA0: BF89FC07
	v_add_f32_e32 v1, v1, v3                                   // 000000187CA4: 06020701
	ds_bpermute_b32 v3, v4, v1                                 // 000000187CA8: DACC0000 03000104
	v_xor_b32_e32 v4, 2, v0                                    // 000000187CB0: 3A080082
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000187CB4: BF8700B1
	v_cmp_gt_i32_e32 vcc_lo, 32, v4                            // 000000187CB8: 7C8808A0
	v_cndmask_b32_e32 v4, v0, v4, vcc_lo                       // 000000187CBC: 02080900
	s_waitcnt lgkmcnt(0)                                       // 000000187CC0: BF89FC07
	v_dual_add_f32 v1, v1, v3 :: v_dual_lshlrev_b32 v4, 2, v4  // 000000187CC4: C9220701 01040882
	ds_bpermute_b32 v3, v4, v1                                 // 000000187CCC: DACC0000 03000104
	v_xor_b32_e32 v4, 1, v0                                    // 000000187CD4: 3A080081
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_2)// 000000187CD8: BF870131
	v_cmp_gt_i32_e32 vcc_lo, 32, v4                            // 000000187CDC: 7C8808A0
	v_cndmask_b32_e32 v0, v0, v4, vcc_lo                       // 000000187CE0: 02000900
	v_cmp_eq_u32_e32 vcc_lo, 0, v2                             // 000000187CE4: 7C940480
	v_lshlrev_b32_e32 v4, 2, v0                                // 000000187CE8: 30080082
	s_waitcnt lgkmcnt(0)                                       // 000000187CEC: BF89FC07
	v_add_f32_e32 v0, v1, v3                                   // 000000187CF0: 06000701
	ds_bpermute_b32 v1, v4, v0                                 // 000000187CF4: DACC0000 01000004
	s_and_b32 exec_lo, exec_lo, vcc_lo                         // 000000187CFC: 8B7E6A7E
	s_cbranch_execz 17                                         // 000000187D00: BFA50011 <_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj+0x948>
	s_load_b64 s[0:1], s[0:1], 0x68                            // 000000187D04: F4040000 F8000068
	s_mul_i32 s3, s10, s6                                      // 000000187D0C: 9603060A
	s_waitcnt lgkmcnt(0)                                       // 000000187D10: BF89FC07
	v_dual_add_f32 v0, v0, v1 :: v_dual_mov_b32 v1, 0          // 000000187D14: C9100300 00000080
	s_add_i32 s2, s3, s2                                       // 000000187D1C: 81020203
	s_mul_i32 s3, s14, s4                                      // 000000187D20: 9603040E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 000000187D24: BF8704A9
	s_add_i32 s2, s2, s3                                       // 000000187D28: 81020302
	s_mov_b32 s3, 0                                            // 000000187D2C: BE830080
	s_lshl_b64 s[2:3], s[2:3], 2                               // 000000187D30: 84828202
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000187D34: BF870009
	s_add_u32 s0, s0, s2                                       // 000000187D38: 80000200
	s_addc_u32 s1, s1, s3                                      // 000000187D3C: 82010301
	global_store_b32 v1, v0, s[0:1]                            // 000000187D40: DC6A0000 00000001
	s_endpgm                                                   // 000000187D48: BFB00000
		...
