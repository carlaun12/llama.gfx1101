_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj: ; @_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj
; %bb.0:
	s_clause 0x1
	s_load_b64 s[8:9], s[0:1], 0x10
	s_load_b128 s[16:19], s[0:1], 0x70
	s_mov_b32 s6, s3
	s_waitcnt lgkmcnt(0)
	s_cmp_lg_u64 s[8:9], 0
	s_cselect_b32 s5, -1, 0
	s_cmp_eq_u64 s[8:9], 0
	s_cbranch_scc1 .LBB309_5
; %bb.1:
	s_mov_b32 s7, 0
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_lshl_b64 s[10:11], s[6:7], 2
	s_add_u32 s8, s8, s10
	s_addc_u32 s9, s9, s11
	s_load_b32 s3, s[8:9], 0x0
	s_clause 0x1
	s_load_b128 s[8:11], s[0:1], 0x98
	s_load_b32 s20, s[0:1], 0x80
	s_cbranch_execnz .LBB309_3
.LBB309_2:
	s_load_b64 s[12:13], s[0:1], 0x8c
	s_waitcnt lgkmcnt(0)
	s_mul_hi_u32 s3, s12, s6
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_add_i32 s3, s6, s3
	s_lshr_b32 s3, s3, s13
.LBB309_3:
	s_load_b32 s21, s[0:1], 0xa8
	s_and_not1_b32 vcc_lo, exec_lo, s5
	s_cbranch_vccnz .LBB309_6
; %bb.4:
	s_mul_hi_u32 s5, s17, s6
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_add_i32 s5, s6, s5
	s_lshr_b32 s5, s5, s18
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_mul_i32 s5, s5, s19
	s_sub_i32 s17, s6, s5
	s_branch .LBB309_7
.LBB309_5:
                                        ; implicit-def: $sgpr3
	s_clause 0x1
	s_load_b128 s[8:11], s[0:1], 0x98
	s_load_b32 s20, s[0:1], 0x80
	s_branch .LBB309_2
.LBB309_6:
	s_mov_b32 s17, s6
.LBB309_7:
	s_load_b128 s[12:15], s[0:1], 0xb0
	v_bfe_u32 v3, v0, 10, 10
	v_dual_mov_b32 v5, 0 :: v_dual_and_b32 v2, 0x3ff, v0
	s_lshr_b32 s7, s16, 8
	s_mov_b32 s5, exec_lo
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshl_or_b32 v0, v3, 5, v2
	v_lshrrev_b32_e32 v4, 3, v0
	s_delay_alu instid0(VALU_DEP_1)
	v_cmpx_gt_u32_e64 s7, v4
	s_cbranch_execz .LBB309_11
; %bb.8:
	v_lshrrev_b32_e32 v5, 3, v0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s9, s17, s9
	v_and_b32_e32 v6, 7, v2
	s_mul_hi_u32 s17, s9, 36
	s_mul_i32 s16, s9, 36
	s_mul_i32 s9, s13, s4
	v_mad_u64_u32 v[0:1], null, 0x120, v5, s[16:17]
	s_load_b128 s[16:19], s[0:1], 0x0
	v_lshlrev_b32_e32 v9, 1, v2
	v_mov_b32_e32 v5, 0
	s_mul_i32 s3, s3, s8
	s_mul_i32 s20, s20, s2
	v_mad_u64_u32 v[7:8], null, s9, 36, v[0:1]
	v_and_b32_e32 v10, 14, v9
	s_mul_hi_u32 s9, s11, s4
	s_mov_b32 s11, 0
	s_add_i32 s9, s4, s9
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_lshlrev_b32_e32 v11, 1, v10
	v_mad_u64_u32 v[0:1], null, v6, 36, v[7:8]
	s_lshr_b32 s8, s9, s21
	v_bfe_u32 v7, v9, 2, 2
	s_mul_i32 s8, s8, s12
	v_and_b32_e32 v8, 4, v11
	v_lshlrev_b32_e32 v9, 1, v11
	v_lshlrev_b32_e32 v10, 1, v10
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s18, v0
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v1, null, s19, v1, vcc_lo
	s_add_i32 s8, s8, s20
	v_add_co_u32 v0, vcc_lo, v0, 32
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo
	s_add_i32 s12, s3, s8
.LBB309_9:                              ; =>This Inner Loop Header: Depth=1
	s_delay_alu instid0(SALU_CYCLE_1)
	v_add_nc_u32_e32 v11, s12, v4
	s_getpc_b64 s[8:9]
	s_add_u32 s8, s8, _ZL9iq3s_grid@rel32@lo+4
	s_addc_u32 s9, s9, _ZL9iq3s_grid@rel32@hi+12
	v_add_nc_u32_e32 v4, 4, v4
	v_mad_i64_i32 v[19:20], null, 0x6e, v11, s[16:17]
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_1)
	v_cmp_le_u32_e64 s3, s7, v4
	s_or_b32 s11, s3, s11
	v_add_co_u32 v11, vcc_lo, v19, v9
	v_add_co_ci_u32_e64 v12, null, 0, v20, vcc_lo
	v_add_co_u32 v13, vcc_lo, v19, v6
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v14, null, 0, v20, vcc_lo
	s_clause 0x1
	global_load_b64 v[21:22], v[11:12], off offset:2
	global_load_u8 v27, v[13:14], off offset:66
	v_add_co_u32 v23, vcc_lo, v19, v10
	v_add_co_ci_u32_e64 v24, null, 0, v20, vcc_lo
	v_add_co_u32 v25, vcc_lo, v19, v7
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v26, null, 0, v20, vcc_lo
	s_clause 0x1
	global_load_b128 v[11:14], v[0:1], off offset:-32
	global_load_b128 v[15:18], v[0:1], off offset:-16
	s_clause 0x2
	global_load_b32 v23, v[23:24], off offset:74
	global_load_u8 v24, v[25:26], off offset:106
	global_load_d16_hi_b16 v11, v[19:20], off
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v19, 0xff, v21
	s_waitcnt vmcnt(5)
	v_lshlrev_b32_e32 v20, 8, v27
	v_bfe_u32 v25, v21, 8, 8
	v_lshlrev_b32_e32 v26, 7, v27
	v_bfe_u32 v28, v21, 16, 8
	v_lshlrev_b32_e32 v29, 6, v27
	v_and_or_b32 v19, 0x100, v20, v19
	v_lshrrev_b32_e32 v21, 24, v21
	v_and_or_b32 v25, 0x100, v26, v25
	v_lshlrev_b32_e32 v30, 5, v27
	v_and_b32_e32 v31, 0xff, v22
	v_lshlrev_b32_e32 v19, 2, v19
	v_lshlrev_b32_e32 v32, 4, v27
	v_bfe_u32 v33, v22, 8, 8
	v_lshlrev_b32_e32 v34, 3, v27
	v_lshlrev_b32_e32 v20, 2, v27
	v_lshlrev_b32_e32 v26, 1, v27
	v_and_or_b32 v27, 0x100, v29, v28
	v_lshlrev_b32_e32 v25, 2, v25
	global_load_b32 v19, v19, s[8:9]
	v_and_or_b32 v21, 0x100, v30, v21
	v_and_or_b32 v28, 0x100, v32, v31
	v_lshlrev_b32_e32 v27, 2, v27
	global_load_b32 v25, v25, s[8:9]
	v_and_or_b32 v29, 0x100, v34, v33
	v_bfe_u32 v35, v22, 16, 8
	v_lshrrev_b32_e32 v22, 24, v22
	v_lshlrev_b32_e32 v21, 2, v21
	global_load_b32 v27, v27, s[8:9]
	v_lshlrev_b32_e32 v28, 2, v28
	v_lshlrev_b32_e32 v29, 2, v29
	v_and_or_b32 v22, 0x100, v26, v22
	v_and_or_b32 v20, 0x100, v20, v35
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v30, 15, v23
	s_clause 0x2
	global_load_b32 v28, v28, s[8:9]
	global_load_b32 v26, v29, s[8:9]
	global_load_b32 v21, v21, s[8:9]
	v_lshlrev_b32_e32 v20, 2, v20
	v_lshlrev_b32_e32 v22, 2, v22
	s_clause 0x1
	global_load_b32 v20, v20, s[8:9]
	global_load_b32 v22, v22, s[8:9]
	global_load_b32 v29, v[0:1], off
	v_bfe_u32 v31, v23, 4, 4
	v_mul_u32_u24_e32 v30, 0x204081, v30
	v_bfe_u32 v32, v23, 8, 4
	v_bfe_u32 v33, v23, 12, 4
	v_bfe_u32 v34, v23, 16, 4
	v_mul_u32_u24_e32 v31, 0x204081, v31
	v_and_b32_e32 v30, 0x1010101, v30
	v_mul_u32_u24_e32 v32, 0x204081, v32
	v_mul_u32_u24_e32 v33, 0x204081, v33
	v_bfe_u32 v35, v23, 20, 4
	v_and_b32_e32 v31, 0x1010101, v31
	v_mul_lo_u32 v37, 0xff, v30
	v_and_b32_e32 v32, 0x1010101, v32
	v_mul_u32_u24_e32 v34, 0x204081, v34
	v_and_b32_e32 v33, 0x1010101, v33
	v_mul_lo_u32 v38, 0xff, v31
	v_bfe_u32 v36, v23, 24, 4
	v_mul_u32_u24_e32 v35, 0x204081, v35
	v_and_b32_e32 v34, 0x1010101, v34
	v_lshrrev_b32_e32 v23, 28, v23
	s_waitcnt vmcnt(10)
	v_lshrrev_b32_e32 v24, v8, v24
	v_mul_u32_u24_e32 v36, 0x204081, v36
	v_and_b32_e32 v35, 0x1010101, v35
	v_add_co_u32 v0, vcc_lo, 0x480, v0
	v_mul_u32_u24_e32 v23, 0x204081, v23
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_1) | instid1(VALU_DEP_3)
	v_and_b32_e32 v36, 0x1010101, v36
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo
	v_and_b32_e32 v23, 0x1010101, v23
	s_waitcnt vmcnt(8)
	v_xad_u32 v19, v37, v19, v30
	v_mul_lo_u32 v30, 0xff, v32
	s_waitcnt vmcnt(7)
	v_xad_u32 v25, v38, v25, v31
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_4)
	v_dot4_i32_iu8 v12, v19, v12, 0 neg_lo:[1,1,0]
	v_mul_lo_u32 v19, 0xff, v33
	s_waitcnt vmcnt(6)
	v_xad_u32 v27, v30, v27, v32
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_dot4_i32_iu8 v12, v25, v13, v12 neg_lo:[1,1,0]
	v_mul_lo_u32 v13, 0xff, v34
	v_dot4_i32_iu8 v12, v27, v14, v12 neg_lo:[1,1,0]
	v_mul_lo_u32 v14, 0xff, v35
	s_waitcnt vmcnt(3)
	v_xad_u32 v19, v21, v19, v33
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_xad_u32 v13, v28, v13, v34
	v_dot4_i32_iu8 v12, v19, v15, v12 neg_lo:[1,1,0]
	v_mul_lo_u32 v15, 0xff, v36
	v_xad_u32 v14, v26, v14, v35
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_4)
	v_dot4_i32_iu8 v12, v13, v16, v12 neg_lo:[1,1,0]
	v_mul_lo_u32 v13, 0xff, v23
	s_waitcnt vmcnt(2)
	v_xad_u32 v15, v20, v15, v36
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_4)
	v_dot4_i32_iu8 v12, v14, v17, v12 neg_lo:[1,1,0]
	v_lshlrev_b32_e32 v14, 1, v24
	s_waitcnt vmcnt(1)
	v_xad_u32 v13, v22, v13, v23
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_dot4_i32_iu8 v12, v15, v18, v12 neg_lo:[1,1,0]
	v_and_or_b32 v14, v14, 30, 1
	s_waitcnt vmcnt(0)
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_3)
	v_dot4_i32_iu8 v12, v13, v29, v12 neg_lo:[1,1,0]
	v_cvt_f32_f16_e32 v13, v11.l
	v_cvt_f32_f16_e32 v11, v11.h
	v_mul_lo_u32 v12, v14, v12
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_mul_f32_e32 v11, v11, v13
	v_cvt_f32_i32_e32 v12, v12
	s_delay_alu instid0(VALU_DEP_1)
	v_fmac_f32_e32 v5, v11, v12
	s_and_not1_b32 exec_lo, exec_lo, s11
	s_cbranch_execnz .LBB309_9
; %bb.10:
	s_or_b32 exec_lo, exec_lo, s11
.LBB309_11:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_or_b32 exec_lo, exec_lo, s5
	s_waitcnt lgkmcnt(0)
	; wave barrier
	buffer_gl0_inv
	s_mov_b32 s3, exec_lo
	v_cmpx_eq_u32_e32 0, v3
	s_cbranch_execz .LBB309_14
; %bb.12:
	v_mbcnt_lo_u32_b32 v0, -1, 0
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)
	v_xor_b32_e32 v1, 16, v0
	v_xor_b32_e32 v3, 8, v0
	v_xor_b32_e32 v4, 4, v0
	v_cmp_gt_i32_e32 vcc_lo, 32, v1
	v_cndmask_b32_e32 v1, v0, v1, vcc_lo
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_2) | instid1(VALU_DEP_2)
	v_cmp_gt_i32_e32 vcc_lo, 32, v3
	v_cndmask_b32_e32 v3, v0, v3, vcc_lo
	v_cmp_gt_i32_e32 vcc_lo, 32, v4
	v_dual_cndmask_b32 v4, v0, v4 :: v_dual_lshlrev_b32 v3, 2, v3
	s_delay_alu instid0(VALU_DEP_1)
	v_lshlrev_b32_e32 v4, 2, v4
	v_lshlrev_b32_e32 v1, 2, v1
	ds_bpermute_b32 v1, v1, v5
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v5, v1
	ds_bpermute_b32 v3, v3, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v1, v3
	ds_bpermute_b32 v3, v4, v1
	v_xor_b32_e32 v4, 2, v0
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
	v_cmp_gt_i32_e32 vcc_lo, 32, v4
	v_cndmask_b32_e32 v4, v0, v4, vcc_lo
	s_waitcnt lgkmcnt(0)
	v_dual_add_f32 v1, v1, v3 :: v_dual_lshlrev_b32 v4, 2, v4
	ds_bpermute_b32 v3, v4, v1
	v_xor_b32_e32 v4, 1, v0
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_2)
	v_cmp_gt_i32_e32 vcc_lo, 32, v4
	v_cndmask_b32_e32 v0, v0, v4, vcc_lo
	v_cmp_eq_u32_e32 vcc_lo, 0, v2
	v_lshlrev_b32_e32 v4, 2, v0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v1, v3
	ds_bpermute_b32 v1, v4, v0
	s_and_b32 exec_lo, exec_lo, vcc_lo
	s_cbranch_execz .LBB309_14
; %bb.13:
	s_load_b64 s[0:1], s[0:1], 0x68
	s_mul_i32 s3, s10, s6
	s_waitcnt lgkmcnt(0)
	v_dual_add_f32 v0, v0, v1 :: v_dual_mov_b32 v1, 0
	s_add_i32 s2, s3, s2
	s_mul_i32 s3, s14, s4
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)
	s_add_i32 s2, s2, s3
	s_mov_b32 s3, 0
	s_lshl_b64 s[2:3], s[2:3], 2
	s_delay_alu instid0(SALU_CYCLE_1)
	s_add_u32 s0, s0, s2
	s_addc_u32 s1, s1, s3
	global_store_b32 v1, v0, s[0:1]
.LBB309_14:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 192
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
		.amdhsa_next_free_vgpr 39
		.amdhsa_next_free_sgpr 22
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
		.amdhsa_inst_pref_size 15
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.section	.text._ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj,"axG",@progbits,_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj,comdat
.Lfunc_end309:
	.size	_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj, .Lfunc_end309-_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj
                                        
