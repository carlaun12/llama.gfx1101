_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj: ; @_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj
; %bb.0:
	s_clause 0x2
	s_load_b128 s[24:27], s[0:1], 0x48
	s_load_b128 s[28:31], s[0:1], 0x20
	s_load_b256 s[8:15], s[0:1], 0x0
	s_mov_b32 s20, s3
	s_waitcnt lgkmcnt(0)
	s_cmp_lg_u64 s[24:25], 0
	s_cbranch_scc0 .LBB241_29
; %bb.1:
	s_load_b32 s3, s[0:1], 0xc4
	s_waitcnt lgkmcnt(0)
	s_add_i32 s3, s3, -1
	s_delay_alu instid0(SALU_CYCLE_1)
	s_cmp_eq_u32 s20, s3
	s_cselect_b32 s5, -1, 0
	s_clause 0x1
	s_load_b128 s[36:39], s[0:1], 0x70
	s_load_b128 s[16:19], s[0:1], 0x98
	s_cbranch_execnz .LBB241_3
.LBB241_2:
	s_mov_b32 s5, 0
.LBB241_3:
	s_clause 0x1
	s_load_b32 s41, s[0:1], 0x80
	s_load_b32 s40, s[0:1], 0xa8
	s_and_b32 vcc_lo, exec_lo, s5
	s_mov_b32 s42, 0
	s_cbranch_vccnz .LBB241_7
; %bb.4:
	s_cmp_eq_u64 s[12:13], 0
	s_mov_b32 s21, 0
	s_cbranch_scc1 .LBB241_30
; %bb.5:
	s_lshl_b64 s[6:7], s[20:21], 2
	s_delay_alu instid0(SALU_CYCLE_1)
	s_add_u32 s6, s12, s6
	s_addc_u32 s7, s13, s7
	s_load_b32 s42, s[6:7], 0x0
	s_and_not1_b32 vcc_lo, exec_lo, s21
	s_cbranch_vccnz .LBB241_7
.LBB241_6:
	s_load_b64 s[6:7], s[0:1], 0x8c
	s_waitcnt lgkmcnt(0)
	s_mul_hi_u32 s3, s20, s6
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_add_i32 s3, s20, s3
	s_lshr_b32 s42, s3, s7
.LBB241_7:
	s_load_b64 s[6:7], s[0:1], 0x58
	s_and_b32 s3, exec_lo, s5
	s_cselect_b32 s33, 0, s20
	s_cmp_eq_u64 s[12:13], 0
	s_mov_b32 s3, s33
	s_mov_b32 s43, s33
	s_cbranch_scc1 .LBB241_9
; %bb.8:
	s_waitcnt lgkmcnt(0)
	s_mul_hi_u32 s3, s33, s37
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_add_i32 s3, s33, s3
	s_lshr_b32 s3, s3, s38
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_mul_i32 s3, s3, s39
	s_sub_i32 s43, s33, s3
	s_mov_b32 s3, s42
.LBB241_9:
	s_clause 0x1
	s_load_b64 s[12:13], s[0:1], 0x40
	s_load_b128 s[20:23], s[0:1], 0xb0
	v_bfe_u32 v13, v0, 10, 10
	v_dual_mov_b32 v11, 0 :: v_dual_and_b32 v10, 0x3ff, v0
	v_mov_b32_e32 v12, 0
	s_cmp_lg_u64 s[28:29], 0
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s37, exec_lo
	v_or_b32_e32 v0, v10, v13
	s_cselect_b32 s23, -1, 0
	s_delay_alu instid0(VALU_DEP_1)
	v_cmpx_eq_u32_e32 0, v0
	s_cbranch_execz .LBB241_14
; %bb.10:
	v_dual_mov_b32 v11, 0 :: v_dual_lshlrev_b32 v0, 2, v10
	v_mov_b32_e32 v12, 0
	s_cmp_eq_u64 s[14:15], 0
	s_mul_i32 s34, s3, s18
	s_cbranch_scc1 .LBB241_12
; %bb.11:
	s_mul_i32 s38, s22, s4
	s_mov_b32 s39, 0
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)
	s_lshl_b64 s[44:45], s[38:39], 2
	s_mov_b32 s35, s39
	s_add_u32 s3, s14, s44
	s_addc_u32 s38, s15, s45
	s_lshl_b64 s[14:15], s[34:35], 2
	s_add_u32 s35, s3, s14
	s_addc_u32 s38, s38, s15
	s_ashr_i32 s3, s2, 31
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_lshl_b64 s[14:15], s[2:3], 2
	s_add_u32 s14, s35, s14
	s_addc_u32 s15, s38, s15
	global_load_b32 v12, v0, s[14:15]
.LBB241_12:
	s_cmp_lg_u64 s[30:31], 0
	s_cselect_b32 s3, -1, 0
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_and_b32 s3, s3, s23
	s_and_not1_b32 vcc_lo, exec_lo, s3
	s_cbranch_vccnz .LBB241_14
; %bb.13:
	s_mul_i32 s14, s22, s4
	s_mov_b32 s15, 0
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)
	s_lshl_b64 s[38:39], s[14:15], 2
	s_mov_b32 s35, s15
	s_add_u32 s3, s30, s38
	s_addc_u32 s30, s31, s39
	s_lshl_b64 s[14:15], s[34:35], 2
	s_add_u32 s31, s3, s14
	s_addc_u32 s30, s30, s15
	s_ashr_i32 s3, s2, 31
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_lshl_b64 s[14:15], s[2:3], 2
	s_add_u32 s14, s31, s14
	s_addc_u32 s15, s30, s15
	global_load_b32 v11, v0, s[14:15]
.LBB241_14:
	s_or_b32 exec_lo, exec_lo, s37
	v_lshl_add_u32 v0, v13, 5, v10
	v_dual_mov_b32 v16, 0 :: v_dual_mov_b32 v15, 0
	v_cndmask_b32_e64 v14, 0, 1, s23
	s_lshr_b32 s30, s36, 8
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_lshrrev_b32_e32 v17, 3, v0
	s_mov_b32 s31, exec_lo
	v_cmpx_gt_u32_e64 s30, v17
	s_cbranch_execz .LBB241_20
; %bb.15:
	v_lshrrev_b32_e32 v2, 3, v0
	s_mul_i32 s3, s43, s17
	v_dual_mov_b32 v16, 0 :: v_dual_and_b32 v5, 7, v10
	s_mul_hi_u32 s15, s3, 36
	s_mul_i32 s14, s3, 36
	v_dual_mov_b32 v15, 0 :: v_dual_lshlrev_b32 v4, 1, v10
	v_mad_u64_u32 v[0:1], null, 0x120, v2, s[14:15]
	s_mul_i32 s14, s21, s4
	v_and_b32_e32 v4, 14, v4
	s_mul_hi_u32 s3, s19, s4
	s_mul_i32 s41, s41, s2
	s_add_i32 s3, s4, s3
	s_mul_i32 s17, s42, s16
	v_mad_u64_u32 v[2:3], null, s14, 36, v[0:1]
	s_lshr_b32 s3, s3, s40
	s_and_b32 s14, exec_lo, s5
	s_mul_i32 s3, s3, s20
	v_lshlrev_b32_e32 v19, 1, v4
	s_cselect_b32 s15, s27, s29
	s_cselect_b32 s14, s26, s28
	v_mad_u64_u32 v[0:1], null, v5, 36, v[2:3]
	v_lshlrev_b32_e32 v2, 1, v4
	s_cselect_b32 s9, s25, s9
	s_cselect_b32 s8, s24, s8
	s_add_i32 s3, s3, s41
	s_mov_b32 s16, 0
	v_lshlrev_b32_e32 v18, 1, v2
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_co_u32 v0, vcc_lo, s10, v0
	v_add_co_ci_u32_e64 v1, null, s11, v1, vcc_lo
	s_add_i32 s17, s17, s3
	v_add_co_u32 v8, vcc_lo, v0, 32
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v9, null, 0, v1, vcc_lo
	s_getpc_b64 s[10:11]
	s_add_u32 s10, s10, _ZL11iq3xxs_grid@rel32@lo+4
	s_addc_u32 s11, s11, _ZL11iq3xxs_grid@rel32@hi+12
	s_branch .LBB241_17
.LBB241_16:                             ;   in Loop: Header=BB241_17 Depth=1
	v_and_b32_e32 v31, 0xff, v20
	v_bfe_u32 v32, v20, 7, 8
	v_bfe_u32 v33, v20, 14, 8
	v_bfe_u32 v35, v20, 21, 8
	v_add_nc_u32_e32 v17, 4, v17
	v_bcnt_u32_b32 v34, v31, 0
	v_bcnt_u32_b32 v36, v32, 0
	v_bcnt_u32_b32 v37, v33, 0
	v_bcnt_u32_b32 v38, v35, 0
	v_cmp_le_u32_e32 vcc_lo, s30, v17
	v_and_b32_e32 v34, 1, v34
	v_and_b32_e32 v36, 1, v36
	v_and_b32_e32 v37, 1, v37
	v_and_b32_e32 v38, 1, v38
	v_add_co_u32 v8, s3, 0x480, v8
	v_lshlrev_b32_e32 v34, 7, v34
	v_lshlrev_b32_e32 v36, 7, v36
	v_lshlrev_b32_e32 v37, 7, v37
	v_add_co_ci_u32_e64 v9, null, 0, v9, s3
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
	v_xor_b32_e32 v31, v34, v31
	v_xor_b32_e32 v32, v36, v32
	s_delay_alu instid0(VALU_DEP_4)
	v_xor_b32_e32 v33, v37, v33
	v_lshlrev_b32_e32 v34, 7, v38
	s_waitcnt vmcnt(7)
	v_and_b32_e32 v36, 0x80808080, v30
	v_mul_lo_u32 v31, 0x1010101, v31
	v_mul_lo_u32 v32, 0x1010101, v32
	v_mul_lo_u32 v33, 0x1010101, v33
	v_xor_b32_e32 v34, v34, v35
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v35, 0x80808080, v29
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v37, 0x80808080, v28
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v38, 0x80808080, v27
	s_or_b32 s16, vcc_lo, s16
	v_and_b32_e32 v39, 0x8040201, v31
	v_and_b32_e32 v31, 0x80402010, v31
	v_and_b32_e32 v40, 0x8040201, v32
	v_and_b32_e32 v32, 0x80402010, v32
	v_and_b32_e32 v41, 0x8040201, v33
	v_add_nc_u32_e32 v39, 0x7f7f7f7f, v39
	v_add_nc_u32_e32 v31, 0x7f7f7f7f, v31
	v_add_nc_u32_e32 v40, 0x7f7f7f7f, v40
	v_add_nc_u32_e32 v32, 0x7f7f7f7f, v32
	v_mul_lo_u32 v34, 0x1010101, v34
	v_lshrrev_b32_e32 v39, 7, v39
	v_lshrrev_b32_e32 v31, 7, v31
	v_lshrrev_b32_e32 v40, 7, v40
	v_lshrrev_b32_e32 v32, 7, v32
	v_and_b32_e32 v33, 0x80402010, v33
	v_and_b32_e32 v39, 0x1010101, v39
	v_and_b32_e32 v31, 0x1010101, v31
	v_and_b32_e32 v40, 0x1010101, v40
	v_add_nc_u32_e32 v41, 0x7f7f7f7f, v41
	v_and_b32_e32 v32, 0x1010101, v32
	v_mul_lo_u32 v39, 0xff, v39
	v_mul_lo_u32 v31, 0xff, v31
	v_mul_lo_u32 v40, 0xff, v40
	v_and_b32_e32 v42, 0x8040201, v34
	v_add_nc_u32_e32 v33, 0x7f7f7f7f, v33
	v_lshrrev_b32_e32 v41, 7, v41
	v_mul_lo_u32 v32, 0xff, v32
	v_and_b32_e32 v34, 0x80402010, v34
	v_xor_b32_e32 v30, v39, v30
	v_and_b32_e32 v39, 0x7f7f7f7f, v39
	v_xor_b32_e32 v29, v31, v29
	v_and_b32_e32 v31, 0x7f7f7f7f, v31
	v_xor_b32_e32 v28, v40, v28
	v_or_b32_e32 v30, 0x80808080, v30
	v_add_nc_u32_e32 v42, 0x7f7f7f7f, v42
	v_or_b32_e32 v29, 0x80808080, v29
	v_lshrrev_b32_e32 v33, 7, v33
	v_and_b32_e32 v41, 0x1010101, v41
	v_sub_nc_u32_e32 v30, v30, v39
	v_and_b32_e32 v40, 0x7f7f7f7f, v40
	v_sub_nc_u32_e32 v29, v29, v31
	v_xor_b32_e32 v27, v32, v27
	v_or_b32_e32 v28, 0x80808080, v28
	v_xor3_b32 v30, v36, v30, 0x80808080
	v_add_nc_u32_e32 v34, 0x7f7f7f7f, v34
	v_lshrrev_b32_e32 v42, 7, v42
	v_and_b32_e32 v33, 0x1010101, v33
	v_mul_lo_u32 v41, 0xff, v41
	v_xor3_b32 v29, v35, v29, 0x80808080
	v_dot4_i32_iu8 v5, v30, v5, 0 neg_lo:[1,1,0]
	v_and_b32_e32 v32, 0x7f7f7f7f, v32
	v_or_b32_e32 v27, 0x80808080, v27
	v_sub_nc_u32_e32 v28, v28, v40
	v_mul_lo_u32 v31, 0xff, v33
	v_lshrrev_b32_e32 v30, 7, v34
	v_dot4_i32_iu8 v5, v29, v6, v5 neg_lo:[1,1,0]
	v_and_b32_e32 v6, 0x1010101, v42
	v_sub_nc_u32_e32 v27, v27, v32
	s_waitcnt vmcnt(3)
	v_xor_b32_e32 v32, v41, v26
	v_xor3_b32 v28, v37, v28, 0x80808080
	v_and_b32_e32 v30, 0x1010101, v30
	v_mul_lo_u32 v6, 0xff, v6
	v_xor3_b32 v27, v38, v27, 0x80808080
	v_or_b32_e32 v29, 0x80808080, v32
	s_waitcnt vmcnt(2)
	v_xor_b32_e32 v32, v31, v25
	v_and_b32_e32 v33, 0x7f7f7f7f, v41
	v_dot4_i32_iu8 v5, v28, v7, v5 neg_lo:[1,1,0]
	v_mul_lo_u32 v30, 0xff, v30
	v_and_b32_e32 v28, 0x7f7f7f7f, v31
	v_or_b32_e32 v7, 0x80808080, v32
	v_sub_nc_u32_e32 v29, v29, v33
	v_and_b32_e32 v26, 0x80808080, v26
	v_dot4_i32_iu8 v0, v27, v0, v5 neg_lo:[1,1,0]
	s_waitcnt vmcnt(1)
	v_xor_b32_e32 v5, v24, v6
	v_sub_nc_u32_e32 v7, v7, v28
	v_and_b32_e32 v25, 0x80808080, v25
	v_xor3_b32 v26, v26, v29, 0x80808080
	s_waitcnt vmcnt(0)
	v_xor_b32_e32 v27, v23, v30
	v_or_b32_e32 v5, 0x80808080, v5
	v_and_b32_e32 v6, 0x7f7f7f7f, v6
	v_xor3_b32 v7, v25, v7, 0x80808080
	v_dot4_i32_iu8 v0, v26, v1, v0 neg_lo:[1,1,0]
	v_or_b32_e32 v1, 0x80808080, v27
	v_and_b32_e32 v25, 0x7f7f7f7f, v30
	v_sub_nc_u32_e32 v5, v5, v6
	v_and_b32_e32 v6, 0x80808080, v24
	v_dot4_i32_iu8 v0, v7, v2, v0 neg_lo:[1,1,0]
	v_and_b32_e32 v2, 0x80808080, v23
	v_sub_nc_u32_e32 v1, v1, v25
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_xor3_b32 v5, v6, v5, 0x80808080
	v_xor3_b32 v1, v2, v1, 0x80808080
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_dot4_i32_iu8 v0, v5, v3, v0 neg_lo:[1,1,0]
	v_lshrrev_b32_e32 v5, 28, v20
	v_dot4_i32_iu8 v3, v1, v21, v0 neg_lo:[1,1,0]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshrrev_b32_e32 v0, 31, v3
	v_add_nc_u32_e32 v0, v3, v0
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_ashrrev_i32_e32 v0, 1, v0
	v_mad_u64_u32 v[1:2], null, v3, v5, v[0:1]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshrrev_b32_e32 v0, 31, v1
	v_add_nc_u32_e32 v0, v1, v0
	v_cvt_f32_f16_e32 v1, v4.h
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_ashrrev_i32_e32 v0, 1, v0
	v_mul_f32_e32 v1, v1, v22
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_cvt_f32_i32_e32 v0, v0
	v_fmac_f32_e32 v16, v1, v0
	s_and_not1_b32 exec_lo, exec_lo, s16
	s_cbranch_execz .LBB241_19
.LBB241_17:                             ; =>This Inner Loop Header: Depth=1
	v_add_nc_u32_e32 v31, s17, v17
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_mad_i64_i32 v[22:23], null, 0x62, v31, s[8:9]
	v_add_co_u32 v0, vcc_lo, v22, v18
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v1, null, 0, v23, vcc_lo
	v_add_co_u32 v26, vcc_lo, v22, v19
	v_add_co_ci_u32_e64 v27, null, 0, v23, vcc_lo
	global_load_b64 v[24:25], v[0:1], off offset:2
	s_clause 0x2
	global_load_b128 v[4:7], v[8:9], off offset:-32
	global_load_b128 v[0:3], v[8:9], off offset:-16
	global_load_b32 v21, v[8:9], off
	s_clause 0x1
	global_load_b32 v20, v[26:27], off offset:66
	global_load_d16_hi_b16 v4, v[22:23], off
	s_and_not1_b32 vcc_lo, exec_lo, s23
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v22, 0xff, v24
	v_lshrrev_b32_e32 v23, 6, v24
	v_lshrrev_b32_e32 v26, 14, v24
	v_lshrrev_b32_e32 v24, 22, v24
	v_and_b32_e32 v27, 0xff, v25
	v_lshrrev_b32_e32 v28, 6, v25
	v_lshrrev_b32_e32 v29, 14, v25
	v_lshrrev_b32_e32 v25, 22, v25
	v_lshlrev_b32_e32 v22, 2, v22
	v_and_b32_e32 v23, 0x3fc, v23
	v_and_b32_e32 v26, 0x3fc, v26
	v_and_b32_e32 v24, 0x3fc, v24
	v_lshlrev_b32_e32 v32, 2, v27
	v_and_b32_e32 v33, 0x3fc, v28
	v_and_b32_e32 v34, 0x3fc, v29
	v_and_b32_e32 v35, 0x3fc, v25
	s_clause 0x7
	global_load_b32 v30, v22, s[10:11]
	global_load_b32 v29, v23, s[10:11]
	global_load_b32 v28, v26, s[10:11]
	global_load_b32 v27, v24, s[10:11]
	global_load_b32 v26, v32, s[10:11]
	global_load_b32 v25, v33, s[10:11]
	global_load_b32 v24, v34, s[10:11]
	global_load_b32 v23, v35, s[10:11]
	s_waitcnt vmcnt(8)
	v_cvt_f32_f16_e32 v22, v4.l
	s_cbranch_vccnz .LBB241_16
; %bb.18:                               ;   in Loop: Header=BB241_17 Depth=1
	v_mad_i64_i32 v[32:33], null, 0x62, v31, s[14:15]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_co_u32 v34, vcc_lo, v32, v18
	v_add_co_ci_u32_e64 v35, null, 0, v33, vcc_lo
	v_add_co_u32 v36, vcc_lo, v32, v19
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v37, null, 0, v33, vcc_lo
	s_clause 0x1
	global_load_b64 v[34:35], v[34:35], off offset:2
	global_load_b32 v31, v[36:37], off offset:66
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v36, 0xff, v34
	v_lshrrev_b32_e32 v37, 6, v34
	v_lshrrev_b32_e32 v38, 14, v34
	v_lshrrev_b32_e32 v34, 22, v34
	v_and_b32_e32 v39, 0xff, v35
	v_lshlrev_b32_e32 v36, 2, v36
	v_and_b32_e32 v37, 0x3fc, v37
	v_and_b32_e32 v38, 0x3fc, v38
	v_and_b32_e32 v34, 0x3fc, v34
	v_lshlrev_b32_e32 v39, 2, v39
	s_clause 0x2
	global_load_b32 v36, v36, s[10:11]
	global_load_b32 v37, v37, s[10:11]
	global_load_b32 v38, v38, s[10:11]
	v_lshrrev_b32_e32 v40, 6, v35
	s_clause 0x1
	global_load_b32 v34, v34, s[10:11]
	global_load_b32 v39, v39, s[10:11]
	v_lshrrev_b32_e32 v41, 14, v35
	v_lshrrev_b32_e32 v35, 22, v35
	v_and_b32_e32 v40, 0x3fc, v40
	s_waitcnt vmcnt(5)
	v_bfe_u32 v44, v31, 21, 8
	v_bfe_u32 v42, v31, 14, 8
	v_and_b32_e32 v41, 0x3fc, v41
	v_and_b32_e32 v35, 0x3fc, v35
	s_clause 0x2
	global_load_b32 v40, v40, s[10:11]
	global_load_b32 v41, v41, s[10:11]
	global_load_b32 v35, v35, s[10:11]
	global_load_d16_b16 v4, v[32:33], off
	v_and_b32_e32 v32, 0xff, v31
	v_bfe_u32 v33, v31, 7, 8
	v_bcnt_u32_b32 v47, v44, 0
	v_bcnt_u32_b32 v46, v42, 0
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
	v_bcnt_u32_b32 v43, v32, 0
	v_bcnt_u32_b32 v45, v33, 0
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
	v_and_b32_e32 v47, 1, v47
	v_and_b32_e32 v46, 1, v46
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
	v_and_b32_e32 v43, 1, v43
	v_and_b32_e32 v45, 1, v45
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_lshlrev_b32_e32 v46, 7, v46
	v_lshlrev_b32_e32 v43, 7, v43
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_lshlrev_b32_e32 v45, 7, v45
	v_xor_b32_e32 v42, v46, v42
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_4)
	v_xor_b32_e32 v32, v43, v32
	v_lshlrev_b32_e32 v43, 7, v47
	v_xor_b32_e32 v33, v45, v33
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
	v_mul_lo_u32 v42, 0x1010101, v42
	v_mul_lo_u32 v32, 0x1010101, v32
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
	v_xor_b32_e32 v43, v43, v44
	v_mul_lo_u32 v33, 0x1010101, v33
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_and_b32_e32 v46, 0x8040201, v42
	v_mul_lo_u32 v43, 0x1010101, v43
	v_and_b32_e32 v44, 0x8040201, v32
	v_and_b32_e32 v32, 0x80402010, v32
	v_and_b32_e32 v45, 0x8040201, v33
	v_and_b32_e32 v33, 0x80402010, v33
	v_and_b32_e32 v42, 0x80402010, v42
	v_add_nc_u32_e32 v44, 0x7f7f7f7f, v44
	v_add_nc_u32_e32 v32, 0x7f7f7f7f, v32
	v_add_nc_u32_e32 v45, 0x7f7f7f7f, v45
	v_add_nc_u32_e32 v33, 0x7f7f7f7f, v33
	v_add_nc_u32_e32 v46, 0x7f7f7f7f, v46
	v_lshrrev_b32_e32 v44, 7, v44
	v_lshrrev_b32_e32 v32, 7, v32
	v_lshrrev_b32_e32 v45, 7, v45
	v_lshrrev_b32_e32 v33, 7, v33
	v_and_b32_e32 v47, 0x8040201, v43
	v_and_b32_e32 v44, 0x1010101, v44
	v_and_b32_e32 v32, 0x1010101, v32
	v_and_b32_e32 v45, 0x1010101, v45
	v_add_nc_u32_e32 v42, 0x7f7f7f7f, v42
	v_lshrrev_b32_e32 v46, 7, v46
	v_mul_lo_u32 v44, 0xff, v44
	v_mul_lo_u32 v32, 0xff, v32
	v_and_b32_e32 v33, 0x1010101, v33
	v_mul_lo_u32 v45, 0xff, v45
	v_and_b32_e32 v43, 0x80402010, v43
	v_add_nc_u32_e32 v47, 0x7f7f7f7f, v47
	v_lshrrev_b32_e32 v42, 7, v42
	v_and_b32_e32 v46, 0x1010101, v46
	v_and_b32_e32 v48, 0x7f7f7f7f, v44
	v_and_b32_e32 v49, 0x7f7f7f7f, v32
	v_mul_lo_u32 v33, 0xff, v33
	v_and_b32_e32 v50, 0x7f7f7f7f, v45
	v_add_nc_u32_e32 v43, 0x7f7f7f7f, v43
	v_lshrrev_b32_e32 v47, 7, v47
	v_and_b32_e32 v42, 0x1010101, v42
	v_mul_lo_u32 v46, 0xff, v46
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_3) | instid1(VALU_DEP_4)
	v_lshrrev_b32_e32 v43, 7, v43
	v_and_b32_e32 v51, 0x7f7f7f7f, v33
	v_and_b32_e32 v47, 0x1010101, v47
	v_mul_lo_u32 v42, 0xff, v42
	v_and_b32_e32 v43, 0x1010101, v43
	v_and_b32_e32 v52, 0x7f7f7f7f, v46
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_mul_lo_u32 v47, 0xff, v47
	v_mul_lo_u32 v43, 0xff, v43
	v_and_b32_e32 v53, 0x7f7f7f7f, v42
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_and_b32_e32 v54, 0x7f7f7f7f, v47
	v_and_b32_e32 v55, 0x7f7f7f7f, v43
	s_waitcnt vmcnt(7)
	v_xor_b32_e32 v32, v32, v37
	v_xor_b32_e32 v44, v44, v36
	v_and_b32_e32 v36, 0x80808080, v36
	s_waitcnt vmcnt(6)
	v_xor_b32_e32 v45, v45, v38
	v_and_b32_e32 v37, 0x80808080, v37
	v_or_b32_e32 v32, 0x80808080, v32
	v_or_b32_e32 v44, 0x80808080, v44
	s_waitcnt vmcnt(5)
	v_xor_b32_e32 v33, v33, v34
	v_or_b32_e32 v45, 0x80808080, v45
	v_and_b32_e32 v38, 0x80808080, v38
	v_sub_nc_u32_e32 v32, v32, v49
	v_sub_nc_u32_e32 v44, v44, v48
	s_waitcnt vmcnt(4)
	v_xor_b32_e32 v46, v46, v39
	v_or_b32_e32 v33, 0x80808080, v33
	v_and_b32_e32 v34, 0x80808080, v34
	v_xor3_b32 v32, v37, v32, 0x80808080
	v_xor3_b32 v36, v36, v44, 0x80808080
	v_sub_nc_u32_e32 v44, v45, v50
	s_waitcnt vmcnt(3)
	v_xor_b32_e32 v37, v42, v40
	v_or_b32_e32 v42, 0x80808080, v46
	v_sub_nc_u32_e32 v33, v33, v51
	v_dot4_i32_iu8 v36, v36, v5, 0 neg_lo:[1,1,0]
	v_xor3_b32 v38, v38, v44, 0x80808080
	v_and_b32_e32 v39, 0x80808080, v39
	v_or_b32_e32 v37, 0x80808080, v37
	v_xor3_b32 v33, v34, v33, 0x80808080
	v_dot4_i32_iu8 v32, v32, v6, v36 neg_lo:[1,1,0]
	v_and_b32_e32 v36, 0x80808080, v40
	v_sub_nc_u32_e32 v40, v42, v52
	s_waitcnt vmcnt(2)
	v_xor_b32_e32 v34, v47, v41
	v_sub_nc_u32_e32 v37, v37, v53
	v_dot4_i32_iu8 v32, v38, v7, v32 neg_lo:[1,1,0]
	s_waitcnt vmcnt(1)
	v_xor_b32_e32 v38, v43, v35
	v_xor3_b32 v39, v39, v40, 0x80808080
	v_and_b32_e32 v35, 0x80808080, v35
	v_xor3_b32 v36, v36, v37, 0x80808080
	v_dot4_i32_iu8 v32, v33, v0, v32 neg_lo:[1,1,0]
	v_or_b32_e32 v33, 0x80808080, v34
	v_and_b32_e32 v34, 0x80808080, v41
	v_or_b32_e32 v38, 0x80808080, v38
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
	v_dot4_i32_iu8 v32, v39, v1, v32 neg_lo:[1,1,0]
	v_sub_nc_u32_e32 v33, v33, v54
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_sub_nc_u32_e32 v37, v38, v55
	v_dot4_i32_iu8 v32, v36, v2, v32 neg_lo:[1,1,0]
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_xor3_b32 v33, v34, v33, 0x80808080
	v_xor3_b32 v34, v35, v37, 0x80808080
	v_lshrrev_b32_e32 v35, 28, v31
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_dot4_i32_iu8 v32, v33, v3, v32 neg_lo:[1,1,0]
	v_dot4_i32_iu8 v34, v34, v21, v32 neg_lo:[1,1,0]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshrrev_b32_e32 v32, 31, v34
	v_add_nc_u32_e32 v32, v34, v32
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_ashrrev_i32_e32 v31, 1, v32
	v_mad_u64_u32 v[32:33], null, v34, v35, v[31:32]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshrrev_b32_e32 v31, 31, v32
	v_add_nc_u32_e32 v31, v32, v31
	s_waitcnt vmcnt(0)
	v_cvt_f32_f16_e32 v32, v4.l
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_ashrrev_i32_e32 v31, 1, v31
	v_mul_f32_e32 v32, v22, v32
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_cvt_f32_i32_e32 v31, v31
	v_fmac_f32_e32 v15, v32, v31
	s_branch .LBB241_16
.LBB241_19:
	s_or_b32 exec_lo, exec_lo, s16
.LBB241_20:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_or_b32 exec_lo, exec_lo, s31
	s_waitcnt vmcnt(0)
	; wave barrier
	buffer_gl0_inv
	s_mov_b32 s3, exec_lo
	v_cmpx_eq_u32_e32 0, v13
	s_cbranch_execz .LBB241_54
; %bb.21:
	v_mbcnt_lo_u32_b32 v1, -1, 0
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)
	v_xor_b32_e32 v0, 16, v1
	v_xor_b32_e32 v3, 8, v1
	v_xor_b32_e32 v4, 4, v1
	v_cmp_gt_i32_e32 vcc_lo, 32, v0
	v_cndmask_b32_e32 v0, v1, v0, vcc_lo
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_2) | instid1(VALU_DEP_2)
	v_cmp_gt_i32_e32 vcc_lo, 32, v3
	v_cndmask_b32_e32 v3, v1, v3, vcc_lo
	v_cmp_gt_i32_e32 vcc_lo, 32, v4
	v_lshlrev_b32_e32 v3, 2, v3
	v_lshlrev_b32_e32 v0, 2, v0
	v_cndmask_b32_e32 v4, v1, v4, vcc_lo
	ds_bpermute_b32 v2, v0, v16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v16, v2
	ds_bpermute_b32 v5, v3, v2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v5
	v_xor_b32_e32 v5, 2, v1
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_cmp_gt_i32_e32 vcc_lo, 32, v5
	v_cndmask_b32_e32 v5, v1, v5, vcc_lo
	v_lshlrev_b32_e32 v5, 2, v5
	v_lshlrev_b32_e32 v4, 2, v4
	ds_bpermute_b32 v6, v4, v2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v6
	v_xor_b32_e32 v6, 1, v1
	ds_bpermute_b32 v7, v5, v2
	v_cmp_gt_i32_e32 vcc_lo, 32, v6
	v_cndmask_b32_e32 v1, v1, v6, vcc_lo
	v_cmp_ne_u32_e32 vcc_lo, 1, v14
	s_delay_alu instid0(VALU_DEP_2)
	v_lshlrev_b32_e32 v6, 2, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v2, v7
	ds_bpermute_b32 v2, v6, v1
	s_cbranch_vccnz .LBB241_23
; %bb.22:
	ds_bpermute_b32 v0, v0, v15
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v15, v0
	ds_bpermute_b32 v3, v3, v0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v3
	ds_bpermute_b32 v3, v4, v0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v3
	ds_bpermute_b32 v3, v5, v0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v3
	ds_bpermute_b32 v3, v6, v0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v15, v0, v3
.LBB241_23:
	v_cmp_eq_u32_e32 vcc_lo, 0, v10
	s_and_b32 exec_lo, exec_lo, vcc_lo
	s_cbranch_execz .LBB241_54
; %bb.24:
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v1, v2
	v_cmp_ne_u32_e32 vcc_lo, 1, v14
	s_delay_alu instid0(VALU_DEP_2)
	v_add_f32_e32 v0, v12, v0
	s_cbranch_vccnz .LBB241_53
; %bb.25:
	v_add_f32_e32 v1, v11, v15
	s_cmp_lt_i32 s12, 3
	s_mov_b32 s3, 0
	s_cbranch_scc1 .LBB241_31
; %bb.26:
	s_cmp_gt_i32 s12, 5
	s_cbranch_scc0 .LBB241_32
; %bb.27:
	s_cmp_eq_u32 s12, 6
	s_cbranch_scc0 .LBB241_33
; %bb.28:
	v_max_f32_e32 v2, v1, v1
	v_max_f32_e64 v3, s13, s13
	s_mov_b32 s8, 0
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_min_f32_e32 v2, v2, v3
	v_mul_f32_e32 v4, 0xbfb8aa3b, v2
	v_cmp_nlt_f32_e32 vcc_lo, 0x42ce8ed0, v2
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_fma_f32 v5, 0xbfb8aa3b, v2, -v4
	v_rndne_f32_e32 v6, v4
	v_dual_fmamk_f32 v5, v2, 0xb2a5705f, v5 :: v_dual_sub_f32 v4, v4, v6
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_add_f32_e32 v4, v4, v5
	v_cvt_i32_f32_e32 v5, v6
	v_exp_f32_e32 v4, v4
	s_waitcnt_depctr 0xfff
	v_ldexp_f32 v4, v4, v5
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2b17218, v2
	v_cndmask_b32_e32 v4, 0x7f800000, v4, vcc_lo
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_f32_e32 v4, 1.0, v4
	v_div_scale_f32 v5, null, v4, v4, v2
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
	v_rcp_f32_e32 v6, v5
	s_waitcnt_depctr 0xfff
	v_fma_f32 v7, -v5, v6, 1.0
	v_fmac_f32_e32 v6, v7, v6
	v_div_scale_f32 v7, vcc_lo, v2, v4, v2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_mul_f32_e32 v8, v7, v6
	v_fma_f32 v9, -v5, v8, v7
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_fmac_f32_e32 v8, v9, v6
	v_max_f32_e64 v9, -s13, -s13
	v_fma_f32 v5, -v5, v8, v7
	v_max_f32_e32 v7, v0, v0
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_div_fmas_f32 v5, v5, v6, v8
	v_minmax_f32 v3, v7, v3, v9
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_div_fixup_f32 v2, v5, v4, v2
	v_mul_f32_e32 v2, v3, v2
	s_branch .LBB241_34
.LBB241_29:
                                        ; implicit-def: $sgpr5
	s_clause 0x1
	s_load_b128 s[36:39], s[0:1], 0x70
	s_load_b128 s[16:19], s[0:1], 0x98
	s_branch .LBB241_2
.LBB241_30:
                                        ; implicit-def: $sgpr42
	s_branch .LBB241_6
.LBB241_31:
	s_mov_b32 s8, 0
                                        ; implicit-def: $vgpr2
	s_cbranch_execnz .LBB241_39
	s_branch .LBB241_44
.LBB241_32:
	s_mov_b32 s8, 0
                                        ; implicit-def: $vgpr2
	s_cbranch_execnz .LBB241_35
	s_branch .LBB241_37
.LBB241_33:
	s_mov_b32 s8, -1
                                        ; implicit-def: $vgpr2
.LBB241_34:
	s_branch .LBB241_37
.LBB241_35:
	s_cmp_eq_u32 s12, 3
	s_cbranch_scc0 .LBB241_38
; %bb.36:
	v_max_f32_e32 v2, v1, v1
	s_mov_b32 s8, 0xc0e00000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_min_f32_e32 v2, 0x40e00000, v2
	v_mul_f32_e32 v3, 0xbfd9db23, v2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3
	v_fma_f32 v5, 0x3fb8aa3b, v3, -v4
	v_rndne_f32_e32 v6, v4
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_dual_fmamk_f32 v5, v3, 0x32a5705f, v5 :: v_dual_sub_f32 v4, v4, v6
	v_add_f32_e32 v4, v4, v5
	v_cvt_i32_f32_e32 v5, v6
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v3
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_1)
	v_exp_f32_e32 v4, v4
	s_waitcnt_depctr 0xfff
	v_ldexp_f32 v4, v4, v5
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v3
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_cndmask_b32_e32 v3, 0x7f800000, v4, vcc_lo
	v_add_f32_e32 v3, 1.0, v3
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_div_scale_f32 v4, null, v3, v3, v2
	v_div_scale_f32 v7, vcc_lo, v2, v3, v2
	v_rcp_f32_e32 v5, v4
	s_waitcnt_depctr 0xfff
	v_fma_f32 v6, -v4, v5, 1.0
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fmac_f32_e32 v5, v6, v5
	v_mul_f32_e32 v6, v7, v5
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fma_f32 v8, -v4, v6, v7
	v_fmac_f32_e32 v6, v8, v5
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fma_f32 v4, -v4, v6, v7
	v_div_fmas_f32 v4, v4, v5, v6
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_div_fixup_f32 v2, v4, v3, v2
	v_max_f32_e32 v7, v0, v0
	v_minmax_f32 v5, v7, 0x40e00000, s8
	s_mov_b32 s8, 0
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_f32_e32 v3, 1.0, v5
	v_mul_f32_e32 v2, v3, v2
.LBB241_37:
	s_branch .LBB241_44
.LBB241_38:
	s_mov_b32 s8, -1
                                        ; implicit-def: $vgpr2
	s_branch .LBB241_44
.LBB241_39:
	s_cmp_gt_i32 s12, 1
	s_cbranch_scc0 .LBB241_41
; %bb.40:
	v_mul_f32_e32 v2, 0xbfb8aa3b, v1
	v_cmp_nlt_f32_e32 vcc_lo, 0x42ce8ed0, v1
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_rndne_f32_e32 v3, v2
	v_fma_f32 v4, 0xbfb8aa3b, v1, -v2
	v_sub_f32_e32 v2, v2, v3
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_fmamk_f32 v4, v1, 0xb2a5705f, v4
	v_cvt_i32_f32_e32 v3, v3
	v_add_f32_e32 v2, v2, v4
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
	v_exp_f32_e32 v2, v2
	s_waitcnt_depctr 0xfff
	v_ldexp_f32 v2, v2, v3
	v_cndmask_b32_e32 v2, 0, v2, vcc_lo
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2b17218, v1
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_cndmask_b32_e32 v2, 0x7f800000, v2, vcc_lo
	v_add_f32_e32 v2, 1.0, v2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_div_scale_f32 v3, null, v2, v2, v1
	v_rcp_f32_e32 v4, v3
	s_waitcnt_depctr 0xfff
	v_fma_f32 v5, -v3, v4, 1.0
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_fmac_f32_e32 v4, v5, v4
	v_div_scale_f32 v5, vcc_lo, v1, v2, v1
	v_mul_f32_e32 v6, v5, v4
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fma_f32 v7, -v3, v6, v5
	v_fmac_f32_e32 v6, v7, v4
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fma_f32 v3, -v3, v6, v5
	v_div_fmas_f32 v3, v3, v4, v6
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_div_fixup_f32 v2, v3, v2, v1
	v_mul_f32_e32 v2, v0, v2
	s_branch .LBB241_42
.LBB241_41:
	s_mov_b32 s3, -1
                                        ; implicit-def: $vgpr2
.LBB241_42:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_not1_b32 vcc_lo, exec_lo, s3
	s_mov_b32 s3, 0
	s_cbranch_vccnz .LBB241_44
; %bb.43:
	s_cmp_lg_u32 s12, 1
	s_mov_b32 s3, -1
	s_cselect_b32 s8, -1, 0
.LBB241_44:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_b32 vcc_lo, exec_lo, s8
	s_cbranch_vccz .LBB241_46
; %bb.45:
	v_mul_f32_e32 v2, v0, v1
	s_mov_b32 s3, 0
.LBB241_46:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_not1_b32 vcc_lo, exec_lo, s3
	s_cbranch_vccnz .LBB241_52
; %bb.47:
	v_mul_f32_e32 v2, 0x3d372713, v1
	v_mul_f32_e32 v3, 0x3f4c422a, v1
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fma_f32 v2, v1, v2, 1.0
	v_mul_f32_e32 v2, v3, v2
                                        ; implicit-def: $vgpr3
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)
	v_cmp_ngt_f32_e64 s3, 0x3f200000, |v2|
	s_and_saveexec_b32 s8, s3
	s_xor_b32 s3, exec_lo, s8
	s_cbranch_execz .LBB241_49
; %bb.48:
	v_add_f32_e64 v3, |v2|, |v2|
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3
	v_cmp_ngt_f32_e32 vcc_lo, 0xc2ce8ed0, v3
	v_rndne_f32_e32 v5, v4
	v_fma_f32 v6, 0x3fb8aa3b, v3, -v4
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_sub_f32_e32 v4, v4, v5
	v_fmamk_f32 v6, v3, 0x32a5705f, v6
	v_cvt_i32_f32_e32 v5, v5
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_f32_e32 v4, v4, v6
	v_exp_f32_e32 v4, v4
	s_waitcnt_depctr 0xfff
	v_ldexp_f32 v4, v4, v5
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_cndmask_b32_e32 v4, 0, v4, vcc_lo
	v_cmp_nlt_f32_e32 vcc_lo, 0x42b17218, v3
	v_cndmask_b32_e32 v3, 0x7f800000, v4, vcc_lo
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_f32_e32 v3, 1.0, v3
	v_rcp_f32_e32 v3, v3
	s_waitcnt_depctr 0xfff
	v_fma_f32 v3, v3, -2.0, 1.0
.LBB241_49:
	s_and_not1_saveexec_b32 s3, s3
	s_cbranch_execz .LBB241_51
; %bb.50:
	v_mul_f32_e32 v3, v2, v2
	s_mov_b32 s8, 0xbbbac73d
	s_delay_alu instid0(VALU_DEP_1) | instid1(SALU_CYCLE_1)
	v_fmaak_f32 v4, s8, v3, 0x3ca908c9
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fmaak_f32 v4, v3, v4, 0xbd5c1c4e
	v_fmaak_f32 v4, v3, v4, 0x3e088382
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fmaak_f32 v4, v3, v4, 0xbeaaaa99
	v_mul_f32_e64 v4, |v2|, v4
	s_delay_alu instid0(VALU_DEP_1)
	v_fma_f32 v3, v3, v4, |v2|
.LBB241_51:
	s_or_b32 exec_lo, exec_lo, s3
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_bfi_b32 v2, 0x7fffffff, v3, v2
	v_dual_mul_f32 v1, 0.5, v1 :: v_dual_add_f32 v2, 1.0, v2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_mul_f32_e32 v1, v1, v2
	v_mul_f32_e32 v2, v0, v1
.LBB241_52:
	s_delay_alu instid0(VALU_DEP_1)
	v_mov_b32_e32 v0, v2
.LBB241_53:
	s_load_b64 s[0:1], s[0:1], 0x68
	s_and_b32 s3, exec_lo, s5
	s_mul_i32 s3, s22, s4
	s_mul_i32 s33, s33, s18
	v_mov_b32_e32 v1, 0
	s_waitcnt lgkmcnt(0)
	s_cselect_b32 s4, s7, s1
	s_cselect_b32 s5, s6, s0
	s_add_i32 s0, s3, s2
	s_mov_b32 s1, 0
	s_add_i32 s0, s0, s33
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s5, s0
	s_addc_u32 s1, s4, s1
	global_store_b32 v1, v0, s[0:1]
.LBB241_54:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 448
		.amdhsa_user_sgpr_count 2
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 56
		.amdhsa_next_free_sgpr 46
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_inst_pref_size 41
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.section	.text._ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj,"axG",@progbits,_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj,comdat
.Lfunc_end241:
	.size	_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj, .Lfunc_end241-_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj
                                        
