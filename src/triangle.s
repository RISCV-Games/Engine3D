#########################################################
# a0 = frame
# a1 = &v1
# a2 = &v2
# a3 = &v3
#########################################################
FLAT_TOP_TRIANGLE:
	# ft0 = m0 = (v3.x-v1.x) / (v3.y-v1.y)
	flw ft0, VECTOR_S_X(a1)
	flw ft1, VECTOR_S_X(a3)
	fsub.s ft0, ft1, ft0
	flw ft1, VECTOR_S_Y(a3)
	flw ft2, VECTOR_S_Y(a1)
	fsub.s ft1, ft1, ft2
	fdiv.s ft0, ft0, ft1

	# ft1 = m1 = (v3.x-v2.x) / (v3.y-v2.y)
	flw ft1, VECTOR_S_X(a3)
	flw ft2, VECTOR_S_X(a2)
	fsub.s ft1, ft1, ft2
	flw ft2, VECTOR_S_Y(a3)
	flw ft3, VECTOR_S_Y(a2)
	fsub.s ft2, ft2, ft3
	fdiv.s ft1, ft1, ft2

	# t0 = y = (int) v1.y
	flw ft2, VECTOR_S_Y(a1)
	fcvt.w.s t0, ft2

	# ft5 = x = fXStart = m0 * (float(y) + 0.5f - v1.y) + v1.x
	flw ft2, VECTOR_S_Y(a1)
	li t1, HALF_S
	fmv.s.x ft3, t1
	fsub.s ft2, ft3, ft2
	fcvt.s.w ft3, t0
	fadd.s ft2, ft2, ft3
	fmul.s ft2, ft2, ft0
	flw ft3, VECTOR_S_X(a1)
	fadd.s ft2, ft2, ft3
	fmv.s ft5, ft2

	# ft6 = xEnd = int(m1 * (float(y) + 0.5f - v2.y) + v2.x)
	flw ft3, VECTOR_S_Y(a2)
	li t3, HALF_S
	fmv.s.x ft4, t3
	fsub.s ft3, ft4, ft3
	fcvt.s.w ft4, t0
	fadd.s ft3, ft3, ft4
	fmul.s ft3, ft3, ft1
	flw ft4, VECTOR_S_X(a2)
	fadd.s ft3, ft3, ft4
	fmv.s ft6, ft3

loop1_flat_top_triangle:
	# if y >= (int)v3.y then break
	flw ft2, VECTOR_S_Y(a3)
	fcvt.w.s t1, ft2
	bge t0, t1, ret_flat_top_triangle

	# t1 = iXStart = (int) fXStart
	fcvt.w.s t1, ft5

	# t2 = iXEnd = (int) fXEnd
	fcvt.w.s t2, ft6

loop2_flat_top_triangle:
	# if x >= xEnd then break
	bge t1, t2, break_loop2_flat_top_triangle

	# pixels[x][y] = white 
	li t3, SCREEN_WIDTH
	mul t3, t0, t3
	add t3, t3, t1
	li t4, SCREEN_BUFFER_ADDRESS
	slli t5, a0, 20
	add t4, t4, t5
	add t3, t4, t3
	li t4, 0xFF
	sb t4, 0(t3)

	# x++
	addi t1, t1, 1
	j loop2_flat_top_triangle

break_loop2_flat_top_triangle:
	# xStart += m0
	fadd.s ft5, ft5, ft0

	# xEnd += m1
	fadd.s ft6, ft6, ft1

continue_loop1_flat_top_triangle:
	# y++
	addi t0, t0, 1
	j loop1_flat_top_triangle

ret_flat_top_triangle:
	ret

#########################################################
# a0 = frame
# a1 = &v1
# a2 = &v2
# a3 = &v3
#########################################################
FLAT_BOTTOM_TRIANGLE:
	# ft0 = m0 = (v2.x-v1.x) / (v2.y-v1.y)
	flw ft0, VECTOR_S_X(a1)
	flw ft1, VECTOR_S_X(a2)
	fsub.s ft0, ft1, ft0
	flw ft1, VECTOR_S_Y(a2)
	flw ft2, VECTOR_S_Y(a1)
	fsub.s ft1, ft1, ft2
	fdiv.s ft0, ft0, ft1

	# ft1 = m1 = (v3.x-v1.x) / (v3.y-v1.y)
	flw ft1, VECTOR_S_X(a3)
	flw ft2, VECTOR_S_X(a1)
	fsub.s ft1, ft1, ft2
	flw ft2, VECTOR_S_Y(a3)
	flw ft3, VECTOR_S_Y(a1)
	fsub.s ft2, ft2, ft3
	fdiv.s ft1, ft1, ft2

	# t0 = y = (int) v1.y
	flw ft2, VECTOR_S_Y(a1)
	fcvt.w.s t0, ft2

	# ft5 = x = fXStart = m0 * (float(y) + 0.5f - v1.y) + v1.x
	flw ft2, VECTOR_S_Y(a1)
	li t1, HALF_S
	fmv.s.x ft3, t1
	fsub.s ft2, ft3, ft2
	fcvt.s.w ft3, t0
	fadd.s ft2, ft2, ft3
	fmul.s ft2, ft2, ft0
	flw ft3, VECTOR_S_X(a1)
	fadd.s ft2, ft2, ft3
	fmv.s ft5, ft2

	fmv.s ft6, ft2

	j loop1_flat_top_triangle