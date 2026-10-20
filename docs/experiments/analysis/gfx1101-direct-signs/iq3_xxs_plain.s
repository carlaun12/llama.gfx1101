_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj: ; @_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj
; %bb.0:
	s_clause 0x1
	s_load_b64 s[8:9], s[0:1], 0x10
	s_load_b128 s[16:19], s[0:1], 0x70
	s_mov_b32 s6, s3
	s_waitcnt lgkmcnt(0)
	s_cmp_lg_u64 s[8:9], 0
	s_cselect_b32 s5, -1, 0
	s_cmp_eq_u64 s[8:9], 0
	s_cbranch_scc1 .LBB242_5
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
	s_cbranch_execnz .LBB242_3
.LBB242_2:
	s_load_b64 s[12:13], s[0:1], 0x8c
	s_waitcnt lgkmcnt(0)
	s_mul_hi_u32 s3, s12, s6
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_add_i32 s3, s6, s3
	s_lshr_b32 s3, s3, s13
.LBB242_3:
	s_load_b32 s21, s[0:1], 0xa8
	s_and_not1_b32 vcc_lo, exec_lo, s5
	s_cbranch_vccnz .LBB242_6
; %bb.4:
	s_mul_hi_u32 s5, s17, s6
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_add_i32 s5, s6, s5
	s_lshr_b32 s5, s5, s18
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_mul_i32 s5, s5, s19
	s_sub_i32 s17, s6, s5
	s_branch .LBB242_7
.LBB242_5:
                                        ; implicit-def: $sgpr3
	s_clause 0x1
	s_load_b128 s[8:11], s[0:1], 0x98
	s_load_b32 s20, s[0:1], 0x80
	s_branch .LBB242_2
.LBB242_6:
	s_mov_b32 s17, s6
.LBB242_7:
	s_load_b128 s[12:15], s[0:1], 0xb0
	v_bfe_u32 v3, v0, 10, 10
	v_and_b32_e32 v2, 0x3ff, v0
	v_mov_b32_e32 v4, 0
	s_lshr_b32 s7, s16, 8
	s_mov_b32 s5, exec_lo
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshl_or_b32 v0, v3, 5, v2
	v_lshrrev_b32_e32 v5, 3, v0
	s_delay_alu instid0(VALU_DEP_1)
	v_cmpx_gt_u32_e64 s7, v5
	s_cbranch_execz .LBB242_11
; %bb.8:
	v_lshrrev_b32_e32 v4, 3, v0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s9, s17, s9
	v_and_b32_e32 v8, 7, v2
	s_mul_hi_u32 s17, s9, 36
	s_mul_i32 s16, s9, 36
	s_mul_i32 s9, s13, s4
	v_mad_u64_u32 v[0:1], null, 0x120, v4, s[16:17]
	s_load_b128 s[16:19], s[0:1], 0x0
	v_lshlrev_b32_e32 v4, 1, v2
	s_mul_i32 s20, s20, s2
	s_mul_i32 s3, s3, s8
	v_mad_u64_u32 v[6:7], null, s9, 36, v[0:1]
	s_mul_hi_u32 s9, s11, s4
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
	s_add_i32 s9, s4, s9
	s_lshr_b32 s9, s9, s21
	v_mad_u64_u32 v[0:1], null, v8, 36, v[6:7]
	v_dual_mov_b32 v4, 0 :: v_dual_and_b32 v7, 14, v4
	s_mul_i32 s8, s9, s12
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	s_add_i32 s8, s8, s20
	v_lshlrev_b32_e32 v6, 1, v7
	s_waitcnt lgkmcnt(0)
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_co_u32 v0, vcc_lo, s18, v0
	v_add_co_ci_u32_e64 v1, null, s19, v1, vcc_lo
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_lshlrev_b32_e32 v6, 1, v6
	v_add_co_u32 v0, vcc_lo, v0, 32
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo
	v_lshlrev_b32_e32 v7, 1, v7
	s_add_i32 s9, s3, s8
	s_mov_b32 s8, 0
.LBB242_9:                              ; =>This Inner Loop Header: Depth=1
	v_add_nc_u32_e32 v10, s9, v5
	s_getpc_b64 s[12:13]
	s_add_u32 s12, s12, _ZL11iq3xxs_grid@rel32@lo+4
	s_addc_u32 s13, s13, _ZL11iq3xxs_grid@rel32@hi+12
	v_add_nc_u32_e32 v5, 4, v5
	v_mad_i64_i32 v[8:9], null, 0x62, v10, s[16:17]
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_1)
	v_cmp_le_u32_e64 s3, s7, v5
	s_or_b32 s8, s3, s8
	v_add_co_u32 v10, vcc_lo, v8, v6
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo
	global_load_b64 v[17:18], v[10:11], off offset:2
	v_add_co_u32 v10, vcc_lo, v8, v7
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo
	s_clause 0x1
	global_load_b32 v19, v[10:11], off offset:66
	global_load_d16_b16 v16, v[8:9], off
	global_load_b128 v[8:11], v[0:1], off offset:-32
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v12, 0xff, v17
	v_lshrrev_b32_e32 v20, 6, v17
	v_lshrrev_b32_e32 v22, 14, v17
	v_lshrrev_b32_e32 v24, 6, v18
	v_lshrrev_b32_e32 v17, 22, v17
	v_lshlrev_b32_e32 v21, 2, v12
	global_load_b128 v[12:15], v[0:1], off offset:-16
	v_and_b32_e32 v20, 0x3fc, v20
	v_and_b32_e32 v22, 0x3fc, v22
	s_waitcnt vmcnt(1)
	v_cvt_f32_f16_e32 v8, v8.l
	v_and_b32_e32 v23, 0xff, v18
	global_load_b32 v21, v21, s[12:13]
	v_and_b32_e32 v24, 0x3fc, v24
	global_load_b32 v22, v22, s[12:13]
	v_and_b32_e32 v17, 0x3fc, v17
	v_lshlrev_b32_e32 v23, 2, v23
	v_lshrrev_b32_e32 v25, 14, v18
	global_load_b32 v24, v24, s[12:13]
	v_lshrrev_b32_e32 v18, 22, v18
	s_clause 0x2
	global_load_b32 v17, v17, s[12:13]
	global_load_b32 v23, v23, s[12:13]
	global_load_b32 v20, v20, s[12:13]
	v_and_b32_e32 v25, 0x3fc, v25
	v_and_b32_e32 v18, 0x3fc, v18
	s_clause 0x1
	global_load_b32 v25, v25, s[12:13]
	global_load_b32 v18, v18, s[12:13]
	global_load_b32 v26, v[0:1], off
	v_and_b32_e32 v27, 0x7f, v19
	v_bfe_u32 v29, v19, 7, 7
	v_and_b32_e32 v28, 15, v19
	v_bfe_u32 v31, v19, 14, 7
	v_bfe_u32 v30, v19, 7, 4
	v_bcnt_u32_b32 v35, v27, 0
	v_bcnt_u32_b32 v36, v29, 0
	v_mul_u32_u24_e32 v28, 0x204081, v28
	v_bcnt_u32_b32 v37, v31, 0
	v_bfe_u32 v33, v19, 21, 7
	v_and_b32_e32 v35, 1, v35
	v_and_b32_e32 v36, 1, v36
	v_and_b32_e32 v28, 0x1010101, v28
	v_mul_u32_u24_e32 v30, 0x204081, v30
	v_and_b32_e32 v37, 1, v37
	v_lshl_or_b32 v27, v35, 7, v27
	v_lshl_or_b32 v29, v36, 7, v29
	v_mul_lo_u32 v35, 0xff, v28
	v_bfe_u32 v32, v19, 14, 4
	v_bcnt_u32_b32 v38, v33, 0
	v_lshrrev_b32_e32 v27, 4, v27
	v_lshrrev_b32_e32 v29, 4, v29
	v_and_b32_e32 v30, 0x1010101, v30
	v_lshl_or_b32 v31, v37, 7, v31
	v_mul_u32_u24_e32 v32, 0x204081, v32
	v_mul_u32_u24_e32 v27, 0x204081, v27
	v_mul_u32_u24_e32 v29, 0x204081, v29
	v_and_b32_e32 v38, 1, v38
	v_mul_lo_u32 v36, 0xff, v30
	v_lshrrev_b32_e32 v31, 4, v31
	v_and_b32_e32 v27, 0x1010101, v27
	v_bfe_u32 v34, v19, 21, 4
	v_and_b32_e32 v32, 0x1010101, v32
	v_lshl_or_b32 v33, v38, 7, v33
	v_mul_u32_u24_e32 v31, 0x204081, v31
	v_mul_lo_u32 v39, 0xff, v27
	v_mul_u32_u24_e32 v34, 0x204081, v34
	v_mul_lo_u32 v37, 0xff, v32
	v_lshrrev_b32_e32 v33, 4, v33
	v_add_co_u32 v0, vcc_lo, 0x480, v0
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_1) | instid1(VALU_DEP_4)
	v_and_b32_e32 v34, 0x1010101, v34
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo
	v_mul_u32_u24_e32 v33, 0x204081, v33
	s_delay_alu instid0(VALU_DEP_3)
	v_mul_lo_u32 v38, 0xff, v34
	s_waitcnt vmcnt(8)
	v_xad_u32 v21, v35, v21, v28
	v_and_b32_e32 v28, 0x1010101, v29
	s_waitcnt vmcnt(7)
	v_xad_u32 v22, v22, v36, v30
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_dot4_i32_iu8 v9, v21, v9, 0 neg_lo:[1,1,0]
	v_mul_lo_u32 v21, 0xff, v28
	s_waitcnt vmcnt(3)
	v_xad_u32 v20, v39, v20, v27
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_xad_u32 v17, v21, v17, v28
	v_dot4_i32_iu8 v9, v20, v10, v9 neg_lo:[1,1,0]
	v_and_b32_e32 v10, 0x1010101, v31
	v_xad_u32 v20, v23, v37, v32
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_dot4_i32_iu8 v9, v22, v11, v9 neg_lo:[1,1,0]
	v_mul_lo_u32 v11, 0xff, v10
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_3)
	v_dot4_i32_iu8 v9, v17, v12, v9 neg_lo:[1,1,0]
	v_and_b32_e32 v12, 0x1010101, v33
	v_xad_u32 v10, v24, v11, v10
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_dot4_i32_iu8 v9, v20, v13, v9 neg_lo:[1,1,0]
	v_mul_lo_u32 v11, 0xff, v12
	s_waitcnt vmcnt(2)
	v_xad_u32 v13, v25, v38, v34
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)
	v_dot4_i32_iu8 v9, v10, v14, v9 neg_lo:[1,1,0]
	s_waitcnt vmcnt(1)
	v_xad_u32 v10, v18, v11, v12
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_2)
	v_dot4_i32_iu8 v9, v13, v15, v9 neg_lo:[1,1,0]
	v_lshrrev_b32_e32 v13, 28, v19
	s_waitcnt vmcnt(0)
	v_dot4_i32_iu8 v12, v10, v26, v9 neg_lo:[1,1,0]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshrrev_b32_e32 v9, 31, v12
	v_add_nc_u32_e32 v9, v12, v9
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_ashrrev_i32_e32 v9, 1, v9
	v_mad_u64_u32 v[10:11], null, v12, v13, v[9:10]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshrrev_b32_e32 v9, 31, v10
	v_add_nc_u32_e32 v9, v10, v9
	v_cvt_f32_f16_e32 v10, v16.l
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_ashrrev_i32_e32 v9, 1, v9
	v_mul_f32_e32 v8, v10, v8
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_cvt_f32_i32_e32 v9, v9
	v_fmac_f32_e32 v4, v8, v9
	s_and_not1_b32 exec_lo, exec_lo, s8
	s_cbranch_execnz .LBB242_9
; %bb.10:
	s_or_b32 exec_lo, exec_lo, s8
.LBB242_11:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_or_b32 exec_lo, exec_lo, s5
	s_waitcnt lgkmcnt(0)
	; wave barrier
	buffer_gl0_inv
	s_mov_b32 s3, exec_lo
	v_cmpx_eq_u32_e32 0, v3
	s_cbranch_execz .LBB242_14
; %bb.12:
	v_mbcnt_lo_u32_b32 v0, -1, 0
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)
	v_xor_b32_e32 v1, 16, v0
	v_xor_b32_e32 v3, 8, v0
	v_cmp_gt_i32_e32 vcc_lo, 32, v1
	v_cndmask_b32_e32 v1, v0, v1, vcc_lo
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_cmp_gt_i32_e32 vcc_lo, 32, v3
	v_lshlrev_b32_e32 v1, 2, v1
	v_cndmask_b32_e32 v3, v0, v3, vcc_lo
	ds_bpermute_b32 v1, v1, v4
	v_lshlrev_b32_e32 v3, 2, v3
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v4, v1
	v_xor_b32_e32 v4, 4, v0
	ds_bpermute_b32 v3, v3, v1
	v_cmp_gt_i32_e32 vcc_lo, 32, v4
	v_cndmask_b32_e32 v4, v0, v4, vcc_lo
	s_waitcnt lgkmcnt(0)
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
	v_dual_add_f32 v1, v1, v3 :: v_dual_lshlrev_b32 v4, 2, v4
	ds_bpermute_b32 v3, v4, v1
	v_xor_b32_e32 v4, 2, v0
	v_cmp_gt_i32_e32 vcc_lo, 32, v4
	v_cndmask_b32_e32 v4, v0, v4, vcc_lo
	s_waitcnt lgkmcnt(0)
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)
	v_dual_add_f32 v1, v1, v3 :: v_dual_lshlrev_b32 v4, 2, v4
	ds_bpermute_b32 v3, v4, v1
	v_xor_b32_e32 v4, 1, v0
	v_cmp_gt_i32_e32 vcc_lo, 32, v4
	v_cndmask_b32_e32 v0, v0, v4, vcc_lo
	v_cmp_eq_u32_e32 vcc_lo, 0, v2
	s_delay_alu instid0(VALU_DEP_2)
	v_lshlrev_b32_e32 v4, 2, v0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v1, v3
	ds_bpermute_b32 v1, v4, v0
	s_and_b32 exec_lo, exec_lo, vcc_lo
	s_cbranch_execz .LBB242_14
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
.LBB242_14:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj
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
		.amdhsa_next_free_vgpr 40
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
		.amdhsa_inst_pref_size 14
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.section	.text._ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj,"axG",@progbits,_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj,comdat
.Lfunc_end242:
	.size	_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj, .Lfunc_end242-_ZL13mul_mat_vec_qIL9ggml_type18ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj
                                        
