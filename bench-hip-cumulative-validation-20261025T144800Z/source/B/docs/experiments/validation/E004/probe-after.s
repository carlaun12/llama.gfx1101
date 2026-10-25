	.amdgcn_target "amdgcn-amd-amdhsa--gfx1101"
	.amdhsa_code_object_version 6
	.text
	.protected	iq3_probe               ; -- Begin function iq3_probe
	.globl	iq3_probe
	.p2align	8
	.type	iq3_probe,@function
iq3_probe:                              ; @iq3_probe
; %bb.0:
	s_load_b128 s[4:7], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 1, v0
	s_getpc_b64 s[2:3]
	s_add_u32 s2, s2, _ZL11iq3xxs_grid@rel32@lo+4
	s_addc_u32 s3, s3, _ZL11iq3xxs_grid@rel32@hi+12
	s_load_b64 s[0:1], s[0:1], 0x10
	v_and_b32_e32 v3, 14, v1
	s_delay_alu instid0(VALU_DEP_1)
	v_lshlrev_b32_e32 v1, 2, v3
	v_lshlrev_b32_e32 v3, 1, v3
	s_waitcnt lgkmcnt(0)
	s_clause 0x1
	global_load_b64 v[1:2], v1, s[4:5] offset:2
	global_load_b32 v11, v3, s[4:5] offset:66
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v3, 0xff, v1
	v_lshrrev_b32_e32 v4, 6, v1
	v_lshrrev_b32_e32 v5, 14, v1
	v_lshrrev_b32_e32 v1, 22, v1
	v_and_b32_e32 v6, 0xff, v2
	v_lshlrev_b32_e32 v3, 2, v3
	v_and_b32_e32 v4, 0x3fc, v4
	v_lshrrev_b32_e32 v7, 6, v2
	v_and_b32_e32 v1, 0x3fc, v1
	v_lshrrev_b32_e32 v8, 14, v2
	v_and_b32_e32 v5, 0x3fc, v5
	s_clause 0x2
	global_load_b32 v12, v3, s[2:3]
	global_load_b32 v13, v4, s[2:3]
	global_load_b32 v15, v1, s[2:3]
	v_lshrrev_b32_e32 v2, 22, v2
	v_lshlrev_b32_e32 v3, 2, v6
	v_and_b32_e32 v4, 0x3fc, v7
	global_load_b32 v14, v5, s[2:3]
	v_and_b32_e32 v1, 0x3fc, v8
	v_and_b32_e32 v2, 0x3fc, v2
	s_clause 0x3
	global_load_b32 v16, v3, s[2:3]
	global_load_b32 v17, v4, s[2:3]
	global_load_b32 v18, v1, s[2:3]
	global_load_b32 v19, v2, s[2:3]
	v_and_b32_e32 v1, 7, v0
	s_waitcnt vmcnt(8)
	v_bfe_u32 v20, v11, 7, 8
	v_bfe_u32 v21, v11, 14, 8
	v_bfe_u32 v23, v11, 21, 8
	v_lshlrev_b32_e32 v0, 2, v0
	v_mad_u64_u32 v[9:10], null, v1, 36, s[6:7]
	s_clause 0x2
	global_load_b128 v[1:4], v[9:10], off
	global_load_b128 v[5:8], v[9:10], off offset:16
	global_load_b32 v9, v[9:10], off offset:32
	v_mov_b32_e32 v10, 0
	v_bcnt_u32_b32 v24, v20, 0
	v_bcnt_u32_b32 v25, v21, 0
	v_bcnt_u32_b32 v26, v23, 0
	global_load_d16_hi_b16 v1, v10, s[4:5]
	v_and_b32_e32 v10, 0xff, v11
	v_and_b32_e32 v24, 1, v24
	v_and_b32_e32 v25, 1, v25
	v_and_b32_e32 v26, 1, v26
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
	v_bcnt_u32_b32 v22, v10, 0
	v_lshlrev_b32_e32 v24, 7, v24
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_lshlrev_b32_e32 v25, 7, v25
	v_and_b32_e32 v22, 1, v22
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_xor_b32_e32 v20, v24, v20
	v_xor_b32_e32 v21, v25, v21
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_lshlrev_b32_e32 v22, 7, v22
	v_mul_lo_u32 v20, 0x1010101, v20
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_mul_lo_u32 v21, 0x1010101, v21
	v_xor_b32_e32 v10, v22, v10
	v_lshlrev_b32_e32 v22, 7, v26
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_3)
	v_and_b32_e32 v24, 0x8040201, v20
	v_mul_lo_u32 v10, 0x1010101, v10
	s_delay_alu instid0(VALU_DEP_3)
	v_xor_b32_e32 v22, v22, v23
	v_and_b32_e32 v20, 0x80402010, v20
	v_and_b32_e32 v25, 0x8040201, v21
	v_and_b32_e32 v21, 0x80402010, v21
	v_add_nc_u32_e32 v24, 0x7f7f7f7f, v24
	v_mul_lo_u32 v22, 0x1010101, v22
	v_add_nc_u32_e32 v20, 0x7f7f7f7f, v20
	v_and_b32_e32 v23, 0x8040201, v10
	v_and_b32_e32 v10, 0x80402010, v10
	v_add_nc_u32_e32 v25, 0x7f7f7f7f, v25
	v_add_nc_u32_e32 v21, 0x7f7f7f7f, v21
	v_lshrrev_b32_e32 v24, 7, v24
	v_add_nc_u32_e32 v23, 0x7f7f7f7f, v23
	v_add_nc_u32_e32 v10, 0x7f7f7f7f, v10
	v_and_b32_e32 v26, 0x8040201, v22
	v_and_b32_e32 v22, 0x80402010, v22
	v_lshrrev_b32_e32 v20, 7, v20
	v_lshrrev_b32_e32 v23, 7, v23
	v_lshrrev_b32_e32 v10, 7, v10
	v_add_nc_u32_e32 v26, 0x7f7f7f7f, v26
	v_add_nc_u32_e32 v22, 0x7f7f7f7f, v22
	v_lshrrev_b32_e32 v25, 7, v25
	v_and_b32_e32 v23, 0x1010101, v23
	v_and_b32_e32 v10, 0x1010101, v10
	v_lshrrev_b32_e32 v21, 7, v21
	v_and_b32_e32 v24, 0x1010101, v24
	v_and_b32_e32 v20, 0x1010101, v20
	v_mul_lo_u32 v23, 0xff, v23
	v_mul_lo_u32 v10, 0xff, v10
	v_lshrrev_b32_e32 v26, 7, v26
	v_lshrrev_b32_e32 v22, 7, v22
	v_and_b32_e32 v25, 0x1010101, v25
	v_and_b32_e32 v21, 0x1010101, v21
	v_mul_lo_u32 v24, 0xff, v24
	v_mul_lo_u32 v20, 0xff, v20
	v_and_b32_e32 v27, 0x7f7f7f7f, v23
	v_and_b32_e32 v28, 0x7f7f7f7f, v10
	v_and_b32_e32 v26, 0x1010101, v26
	v_and_b32_e32 v22, 0x1010101, v22
	v_mul_lo_u32 v25, 0xff, v25
	v_mul_lo_u32 v21, 0xff, v21
	v_and_b32_e32 v29, 0x7f7f7f7f, v24
	v_and_b32_e32 v30, 0x7f7f7f7f, v20
	v_mul_lo_u32 v26, 0xff, v26
	v_mul_lo_u32 v22, 0xff, v22
	v_and_b32_e32 v31, 0x7f7f7f7f, v25
	v_and_b32_e32 v32, 0x7f7f7f7f, v21
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
	v_and_b32_e32 v33, 0x7f7f7f7f, v26
	v_and_b32_e32 v34, 0x7f7f7f7f, v22
	s_waitcnt vmcnt(11)
	v_xor_b32_e32 v23, v23, v12
	s_waitcnt vmcnt(10)
	v_xor_b32_e32 v10, v10, v13
	s_waitcnt vmcnt(9)
	v_xor_b32_e32 v20, v20, v15
	v_and_b32_e32 v12, 0x80808080, v12
	v_and_b32_e32 v13, 0x80808080, v13
	v_or_b32_e32 v23, 0x80808080, v23
	s_waitcnt vmcnt(8)
	v_xor_b32_e32 v24, v24, v14
	v_or_b32_e32 v10, 0x80808080, v10
	v_or_b32_e32 v20, 0x80808080, v20
	s_waitcnt vmcnt(7)
	v_xor_b32_e32 v25, v25, v16
	s_waitcnt vmcnt(6)
	v_xor_b32_e32 v21, v21, v17
	v_or_b32_e32 v24, 0x80808080, v24
	v_sub_nc_u32_e32 v23, v23, v27
	v_sub_nc_u32_e32 v10, v10, v28
	v_and_b32_e32 v14, 0x80808080, v14
	v_and_b32_e32 v15, 0x80808080, v15
	s_waitcnt vmcnt(5)
	v_xor_b32_e32 v26, v18, v26
	s_waitcnt vmcnt(4)
	v_xor_b32_e32 v22, v19, v22
	v_or_b32_e32 v25, 0x80808080, v25
	v_or_b32_e32 v21, 0x80808080, v21
	v_sub_nc_u32_e32 v24, v24, v29
	v_sub_nc_u32_e32 v20, v20, v30
	v_xor3_b32 v12, v12, v23, 0x80808080
	v_xor3_b32 v10, v13, v10, 0x80808080
	v_and_b32_e32 v16, 0x80808080, v16
	v_and_b32_e32 v17, 0x80808080, v17
	v_or_b32_e32 v26, 0x80808080, v26
	v_or_b32_e32 v22, 0x80808080, v22
	v_sub_nc_u32_e32 v25, v25, v31
	v_sub_nc_u32_e32 v21, v21, v32
	v_xor3_b32 v14, v14, v24, 0x80808080
	v_xor3_b32 v15, v15, v20, 0x80808080
	s_waitcnt vmcnt(3)
	v_dot4_i32_iu8 v2, v12, v2, 0 neg_lo:[1,1,0]
	v_dot4_i32_iu8 v3, v10, v3, 0 neg_lo:[1,1,0]
	v_and_b32_e32 v18, 0x80808080, v18
	v_and_b32_e32 v19, 0x80808080, v19
	v_sub_nc_u32_e32 v13, v26, v33
	v_sub_nc_u32_e32 v10, v22, v34
	v_xor3_b32 v12, v16, v25, 0x80808080
	v_xor3_b32 v16, v17, v21, 0x80808080
	v_dot4_i32_iu8 v2, v14, v4, v2 neg_lo:[1,1,0]
	s_waitcnt vmcnt(2)
	v_dot4_i32_iu8 v3, v15, v5, v3 neg_lo:[1,1,0]
	v_xor3_b32 v4, v18, v13, 0x80808080
	v_xor3_b32 v5, v19, v10, 0x80808080
	v_dot4_i32_iu8 v2, v12, v6, v2 neg_lo:[1,1,0]
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_1) | instid1(VALU_DEP_3)
	v_dot4_i32_iu8 v3, v16, v7, v3 neg_lo:[1,1,0]
	v_lshrrev_b32_e32 v6, 28, v11
	v_dot4_i32_iu8 v2, v4, v8, v2 neg_lo:[1,1,0]
	s_waitcnt vmcnt(1)
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_dot4_i32_iu8 v3, v5, v9, v3 neg_lo:[1,1,0]
	v_add_nc_u32_e32 v5, v3, v2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshrrev_b32_e32 v2, 31, v5
	v_add_nc_u32_e32 v2, v5, v2
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_ashrrev_i32_e32 v2, 1, v2
	v_mad_u64_u32 v[3:4], null, v5, v6, v[2:3]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshrrev_b32_e32 v2, 31, v3
	v_add_nc_u32_e32 v2, v3, v2
	s_waitcnt vmcnt(0)
	v_cvt_f32_f16_e32 v3, v1.h
	v_cvt_f32_f16_e32 v1, v1.l
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_ashrrev_i32_e32 v2, 1, v2
	v_mul_f32_e32 v1, v3, v1
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_cvt_f32_i32_e32 v2, v2
	v_mul_f32_e32 v1, v1, v2
	global_store_b32 v0, v1, s[0:1]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel iq3_probe
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 24
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 35
		.amdhsa_next_free_sgpr 8
		.amdhsa_reserve_vcc 0
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
		.amdhsa_inst_pref_size 11
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end0:
	.size	iq3_probe, .Lfunc_end0-iq3_probe
                                        ; -- End function
	.set iq3_probe.num_vgpr, 35
	.set iq3_probe.num_agpr, 0
	.set iq3_probe.numbered_sgpr, 8
	.set iq3_probe.num_named_barrier, 0
	.set iq3_probe.private_seg_size, 0
	.set iq3_probe.uses_vcc, 0
	.set iq3_probe.uses_flat_scratch, 0
	.set iq3_probe.has_dyn_sized_stack, 0
	.set iq3_probe.has_recursion, 0
	.set iq3_probe.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1388
; TotalNumSgprs: 8
; NumVgprs: 35
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 0
; VGPRBlocks: 4
; NumSGPRsForWavesPerEU: 8
; NumVGPRsForWavesPerEU: 35
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 2
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.text
	.p2alignl 7, 3214868480
	.fill 96, 4, 3214868480
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	_ZL11iq3xxs_grid,@object        ; @_ZL11iq3xxs_grid
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
_ZL11iq3xxs_grid:
	.long	67372036                        ; 0x4040404
	.long	67372052                        ; 0x4040414
	.long	67372068                        ; 0x4040424
	.long	67374092                        ; 0x4040c0c
	.long	67374108                        ; 0x4040c1c
	.long	67374142                        ; 0x4040c3e
	.long	67376132                        ; 0x4041404
	.long	67376148                        ; 0x4041414
	.long	67378188                        ; 0x4041c0c
	.long	67380244                        ; 0x4042414
	.long	67386908                        ; 0x4043e1c
	.long	67386924                        ; 0x4043e2c
	.long	67896332                        ; 0x40c040c
	.long	67896348                        ; 0x40c041c
	.long	67898372                        ; 0x40c0c04
	.long	67898388                        ; 0x40c0c14
	.long	67900428                        ; 0x40c140c
	.long	67900460                        ; 0x40c142c
	.long	67902468                        ; 0x40c1c04
	.long	67902484                        ; 0x40c1c14
	.long	67904524                        ; 0x40c240c
	.long	67906596                        ; 0x40c2c24
	.long	67911172                        ; 0x40c3e04
	.long	68420612                        ; 0x4140404
	.long	68420628                        ; 0x4140414
	.long	68420644                        ; 0x4140424
	.long	68422668                        ; 0x4140c0c
	.long	68424708                        ; 0x4141404
	.long	68424724                        ; 0x4141414
	.long	68426764                        ; 0x4141c0c
	.long	68426780                        ; 0x4141c1c
	.long	68426814                        ; 0x4141c3e
	.long	68430860                        ; 0x4142c0c
	.long	68430910                        ; 0x4142c3e
	.long	68435500                        ; 0x4143e2c
	.long	68944908                        ; 0x41c040c
	.long	68944958                        ; 0x41c043e
	.long	68946948                        ; 0x41c0c04
	.long	68946964                        ; 0x41c0c14
	.long	68949036                        ; 0x41c142c
	.long	68959748                        ; 0x41c3e04
	.long	69471260                        ; 0x4240c1c
	.long	69475390                        ; 0x4241c3e
	.long	69477412                        ; 0x4242424
	.long	69479486                        ; 0x4242c3e
	.long	69484060                        ; 0x4243e1c
	.long	69484076                        ; 0x4243e2c
	.long	69993484                        ; 0x42c040c
	.long	69993534                        ; 0x42c043e
	.long	69999636                        ; 0x42c1c14
	.long	70003732                        ; 0x42c2c14
	.long	70523948                        ; 0x4341c2c
	.long	70530084                        ; 0x4343424
	.long	71175172                        ; 0x43e0c04
	.long	71175204                        ; 0x43e0c24
	.long	71175220                        ; 0x43e0c34
	.long	71181340                        ; 0x43e241c
	.long	71185420                        ; 0x43e340c
	.long	201589772                       ; 0xc04040c
	.long	201589788                       ; 0xc04041c
	.long	201591812                       ; 0xc040c04
	.long	201591828                       ; 0xc040c14
	.long	201593868                       ; 0xc04140c
	.long	201593884                       ; 0xc04141c
	.long	201595908                       ; 0xc041c04
	.long	201595924                       ; 0xc041c14
	.long	201595940                       ; 0xc041c24
	.long	201598014                       ; 0xc04243e
	.long	201600004                       ; 0xc042c04
	.long	202114052                       ; 0xc0c0404
	.long	202114068                       ; 0xc0c0414
	.long	202116108                       ; 0xc0c0c0c
	.long	202118148                       ; 0xc0c1404
	.long	202118164                       ; 0xc0c1414
	.long	202638348                       ; 0xc14040c
	.long	202638364                       ; 0xc14041c
	.long	202640388                       ; 0xc140c04
	.long	202640404                       ; 0xc140c14
	.long	202642444                       ; 0xc14140c
	.long	202644484                       ; 0xc141c04
	.long	202653204                       ; 0xc143e14
	.long	203162628                       ; 0xc1c0404
	.long	203162644                       ; 0xc1c0414
	.long	203166724                       ; 0xc1c1404
	.long	203168780                       ; 0xc1c1c0c
	.long	203170868                       ; 0xc1c2434
	.long	203174964                       ; 0xc1c3434
	.long	203686924                       ; 0xc24040c
	.long	203686956                       ; 0xc24042c
	.long	203697156                       ; 0xc242c04
	.long	204215300                       ; 0xc2c1404
	.long	204215332                       ; 0xc2c1424
	.long	204219444                       ; 0xc2c2434
	.long	204226060                       ; 0xc2c3e0c
	.long	204735532                       ; 0xc34042c
	.long	205394964                       ; 0xc3e1414
	.long	205399044                       ; 0xc3e2404
	.long	335807492                       ; 0x14040404
	.long	335807508                       ; 0x14040414
	.long	335809548                       ; 0x14040c0c
	.long	335809564                       ; 0x14040c1c
	.long	335811588                       ; 0x14041404
	.long	335811604                       ; 0x14041414
	.long	335811636                       ; 0x14041434
	.long	335813644                       ; 0x14041c0c
	.long	335815700                       ; 0x14042414
	.long	336331788                       ; 0x140c040c
	.long	336331804                       ; 0x140c041c
	.long	336331820                       ; 0x140c042c
	.long	336333828                       ; 0x140c0c04
	.long	336333844                       ; 0x140c0c14
	.long	336335884                       ; 0x140c140c
	.long	336337924                       ; 0x140c1c04
	.long	336344092                       ; 0x140c341c
	.long	336344126                       ; 0x140c343e
	.long	336346628                       ; 0x140c3e04
	.long	336856068                       ; 0x14140404
	.long	336856084                       ; 0x14140414
	.long	336858124                       ; 0x14140c0c
	.long	336858174                       ; 0x14140c3e
	.long	336860164                       ; 0x14141404
	.long	336860180                       ; 0x14141414
	.long	336862270                       ; 0x14141c3e
	.long	336864260                       ; 0x14142404
	.long	336866348                       ; 0x14142c2c
	.long	337380364                       ; 0x141c040c
	.long	337382404                       ; 0x141c0c04
	.long	337382436                       ; 0x141c0c24
	.long	337395204                       ; 0x141c3e04
	.long	337395236                       ; 0x141c3e24
	.long	337910828                       ; 0x14241c2c
	.long	337914908                       ; 0x14242c1c
	.long	338428956                       ; 0x142c041c
	.long	338433086                       ; 0x142c143e
	.long	338437132                       ; 0x142c240c
	.long	338443812                       ; 0x142c3e24
	.long	339608588                       ; 0x143e040c
	.long	339608604                       ; 0x143e041c
	.long	339610676                       ; 0x143e0c34
	.long	339616812                       ; 0x143e242c
	.long	470025228                       ; 0x1c04040c
	.long	470027268                       ; 0x1c040c04
	.long	470027284                       ; 0x1c040c14
	.long	470029324                       ; 0x1c04140c
	.long	470029340                       ; 0x1c04141c
	.long	470035460                       ; 0x1c042c04
	.long	470037548                       ; 0x1c04342c
	.long	470040084                       ; 0x1c043e14
	.long	470549508                       ; 0x1c0c0404
	.long	470549524                       ; 0x1c0c0414
	.long	470553604                       ; 0x1c0c1404
	.long	470555660                       ; 0x1c0c1c0c
	.long	470557732                       ; 0x1c0c2424
	.long	470557748                       ; 0x1c0c2434
	.long	471073804                       ; 0x1c14040c
	.long	471073820                       ; 0x1c14041c
	.long	471075844                       ; 0x1c140c04
	.long	471077932                       ; 0x1c14142c
	.long	471084052                       ; 0x1c142c14
	.long	471088660                       ; 0x1c143e14
	.long	471600140                       ; 0x1c1c0c0c
	.long	471604252                       ; 0x1c1c1c1c
	.long	472128516                       ; 0x1c241c04
	.long	472130622                       ; 0x1c24243e
	.long	472137236                       ; 0x1c243e14
	.long	472646660                       ; 0x1c2c0404
	.long	472646708                       ; 0x1c2c0434
	.long	472650772                       ; 0x1c2c1414
	.long	472656940                       ; 0x1c2c2c2c
	.long	473173028                       ; 0x1c340c24
	.long	473177140                       ; 0x1c341c34
	.long	473183260                       ; 0x1c34341c
	.long	473832476                       ; 0x1c3e1c1c
	.long	473838596                       ; 0x1c3e3404
	.long	604242980                       ; 0x24040424
	.long	604245054                       ; 0x24040c3e
	.long	604249132                       ; 0x24041c2c
	.long	604249150                       ; 0x24041c3e
	.long	604253212                       ; 0x24042c1c
	.long	604253246                       ; 0x24042c3e
	.long	604782116                       ; 0x240c3e24
	.long	605295620                       ; 0x24141404
	.long	605297726                       ; 0x24141c3e
	.long	605299716                       ; 0x24142404
	.long	605303812                       ; 0x24143404
	.long	605303860                       ; 0x24143434
	.long	605815870                       ; 0x241c043e
	.long	605824044                       ; 0x241c242c
	.long	606340132                       ; 0x24240424
	.long	606350348                       ; 0x24242c0c
	.long	606352420                       ; 0x24243424
	.long	606868524                       ; 0x242c142c
	.long	606872604                       ; 0x242c241c
	.long	606879236                       ; 0x242c3e04
	.long	608044076                       ; 0x243e042c
	.long	608046084                       ; 0x243e0c04
	.long	608046100                       ; 0x243e0c14
	.long	608050180                       ; 0x243e1c04
	.long	738462740                       ; 0x2c040c14
	.long	738468876                       ; 0x2c04240c
	.long	738475524                       ; 0x2c043e04
	.long	738984964                       ; 0x2c0c0404
	.long	738985012                       ; 0x2c0c0434
	.long	738989108                       ; 0x2c0c1434
	.long	738995244                       ; 0x2c0c2c2c
	.long	739511332                       ; 0x2c140c24
	.long	739515412                       ; 0x2c141c14
	.long	739524116                       ; 0x2c143e14
	.long	740033556                       ; 0x2c1c0414
	.long	740043804                       ; 0x2c1c2c1c
	.long	740559876                       ; 0x2c240c04
	.long	740561948                       ; 0x2c24141c
	.long	740561982                       ; 0x2c24143e
	.long	740572692                       ; 0x2c243e14
	.long	741082132                       ; 0x2c2c0414
	.long	741088268                       ; 0x2c2c1c0c
	.long	741616644                       ; 0x2c342c04
	.long	742265892                       ; 0x2c3e1424
	.long	742269972                       ; 0x2c3e2414
	.long	872682532                       ; 0x34041424
	.long	872686628                       ; 0x34042424
	.long	872686644                       ; 0x34042434
	.long	872690724                       ; 0x34043424
	.long	873206796                       ; 0x340c140c
	.long	873214988                       ; 0x340c340c
	.long	873729086                       ; 0x34140c3e
	.long	873739300                       ; 0x34143424
	.long	874257412                       ; 0x341c1c04
	.long	874257460                       ; 0x341c1c34
	.long	874783780                       ; 0x34242424
	.long	875299884                       ; 0x342c042c
	.long	875310100                       ; 0x342c2c14
	.long	875830300                       ; 0x34341c1c
	.long	876479516                       ; 0x343e041c
	.long	876483596                       ; 0x343e140c
	.long	1040450588                      ; 0x3e04041c
	.long	1040450604                      ; 0x3e04042c
	.long	1040450622                      ; 0x3e04043e
	.long	1040452612                      ; 0x3e040c04
	.long	1040456724                      ; 0x3e041c14
	.long	1040460820                      ; 0x3e042c14
	.long	1040978996                      ; 0x3e0c1434
	.long	1040983044                      ; 0x3e0c2404
	.long	1041501204                      ; 0x3e140c14
	.long	1041507372                      ; 0x3e14242c
	.long	1041509396                      ; 0x3e142c14
	.long	1042023428                      ; 0x3e1c0404
	.long	1042025516                      ; 0x3e1c0c2c
	.long	1042029596                      ; 0x3e1c1c1c
	.long	1042035716                      ; 0x3e1c3404
	.long	1042551820                      ; 0x3e24140c
	.long	1042555916                      ; 0x3e24240c
	.long	1043072004                      ; 0x3e2c0404
	.long	1043072020                      ; 0x3e2c0414
	.long	1043076132                      ; 0x3e2c1424
	.long	1043602436                      ; 0x3e341c04
	.size	_ZL11iq3xxs_grid, 1024

	.type	__hip_cuid_79247432295c7ba2,@object ; @__hip_cuid_79247432295c7ba2
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_79247432295c7ba2
__hip_cuid_79247432295c7ba2:
	.byte	0                               ; 0x0
	.size	__hip_cuid_79247432295c7ba2, 1

	.ident	"AMD clang version 22.0.0git (/srcdest/rocm-llvm f58b06dce1f9c15707c5f808fd002e18c2accf7e)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_79247432295c7ba2
	.amdgpu_metadata
---
amdhsa.kernels:
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 24
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           iq3_probe
    .private_segment_fixed_size: 0
    .sgpr_count:     8
    .sgpr_spill_count: 0
    .symbol:         iq3_probe.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     35
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
amdhsa.target:   amdgcn-amd-amdhsa--gfx1101
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
