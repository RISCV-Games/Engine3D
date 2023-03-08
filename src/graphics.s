#########################################################
# a0 = Vector3_SRC
# a1 = Vector2_DEST
#########################################################
PROJECT_3D_2D:
  flw ft0, VECTOR3_F_X(a0)
  flw ft1, VECTOR3_F_Y(a0)
  flw ft2, VECTOR3_F_Z(a0)

  fneg.s ft4, ft3
  fmax.s ft2, ft2, ft4

  li t0, EPSILON
  fmv.s.x ft4, t0
  fadd.s ft2, ft2, ft4

  fdiv.s ft0, ft0, ft2
  fdiv.s ft1, ft1, ft2

  fsw ft0, VECTOR2_F_X(a1)
  fsw ft1, VECTOR2_F_Y(a1)

  ret

#########################################################
# a0 = Vector2
#########################################################
PROJECT_SCREEN_WORD:
  flw ft0, VECTOR2_F_X(a0)
  flw ft1, VECTOR2_F_Y(a0)

  li t0, 1
  fcvt.s.w ft2, t0
  fadd.s ft0, ft0, ft2
  fadd.s ft1, ft1, ft2

  li t0, SCREEN_WIDTH
  li t1, SCREEN_HEIGHT
  fcvt.s.w ft2, t0
  fcvt.s.w ft3, t1

  fmul.s ft0, ft0, ft2
  fmul.s ft1, ft1, ft3

  li t0, 2
  fcvt.s.w ft2, t0
  fdiv.s ft0, ft0, ft2
  fdiv.s ft1, ft1, ft2

  fsw ft0, VECTOR2_F_X(a0)
  fsw ft1, VECTOR2_F_Y(a0)
  ret

#########################################################
# a0 = addr
# a1 = v1
# a2 = v2
# a3 = v3
#########################################################
MAKE_TRIANGLE:
  li t1, 0 
  li t2, 1
  li t3, 2

  flw ft0, VECTOR2_F_Y(a1)
  flw ft1, VECTOR2_F_Y(a3)
  flt.s t4, ft0, ft1 
  bgt t4, zero, make_triangle_no_swap_13

  # Swap 1-3
  SWAP(t4, a1, a3)
  SWAP(t4, t1, t3)

make_triangle_no_swap_13:
  flw ft0, VECTOR2_F_Y(a2)
  flw ft1, VECTOR2_F_Y(a3)
  flt.s t4, ft0, ft1 
  bgt t4, zero, make_triangle_no_swap_23

  # Swap 2 - 3
  SWAP(t4, a2, a3)
  SWAP(t4, t2, t3)

make_triangle_no_swap_23:
  flw ft0, VECTOR2_F_Y(a1)
  flw ft1, VECTOR2_F_Y(a2)
  flt.s t4, ft0, ft1 
  bgt t4, zero, make_triangle_no_swap_12

  # Swap 1 2
  SWAP(t4, a1, a2)
  SWAP(t4, t1, t2)
make_triangle_no_swap_12:
  sw a1, TRIANGLE_W_V1(a0)
  sw a2, TRIANGLE_W_V2(a0)
  sw a3, TRIANGLE_W_V3(a0)
  sb t1, TRIANGLE_B_ORDER0(a0)
  sb t2, TRIANGLE_B_ORDER1(a0)
  sb t3, TRIANGLE_B_ORDER2(a0)
  ret

#########################################################
# a0 = triangule
# a1 = xp
# a2 = yp
#########################################################
TRIANGLE_BARYCENTRIC:
  mv a6, a1
  mv a7, a2

  li t3, 4

  lb t4, TRIANGLE_B_ORDER0(a0)
  mul t4, t4, t3
  add t4, t4, a0

  lb t5, TRIANGLE_B_ORDER1(a0)
  mul t5, t5, t3
  add t5, t5, a0

  lb t6, TRIANGLE_B_ORDER2(a0)
  mul t6, t6, t3
  add t6, t6, a0

  lw t0, 0(t4)
  lw t1, 0(t5)
  lw t2, 0(t6)

  flw fa0, VECTOR2_F_X(t0)
  flw fa1, VECTOR2_F_Y(t0)
  flw fa2, VECTOR2_F_X(t1)
  flw fa3, VECTOR2_F_Y(t1)
  flw fa4, VECTOR2_F_X(t2)
  flw fa5, VECTOR2_F_Y(t2)

  fcvt.w.s a0, fa0
  fcvt.w.s a1, fa1
  fcvt.w.s a2, fa2
  fcvt.w.s a3, fa3
  fcvt.w.s a4, fa4
  fcvt.w.s a5, fa5

  j BARYCENTRIC


#########################################################
# a0 = vector3
# fa0 = x
# fa1 = y
# fa2 = z
#########################################################
TRANSLATE:
  # X
  flw ft0, VECTOR3_F_X(a0)
  fadd.s ft0, ft0, fa0
  fsw ft0, VECTOR3_F_X(a0)

  # Y
  flw ft1, VECTOR3_F_Y(a0)
  fadd.s ft1, ft1, fa1
  fsw ft1, VECTOR3_F_Y(a0)

  # Z
  flw ft2, VECTOR3_F_Z(a0)
  fadd.s ft2, ft2, fa2
  fsw ft2, VECTOR3_F_Z(a0)

  ret

#########################################################
# a0 = vector3
# fa0 = angle
#########################################################
# z = 0..1 y = -1..1| rotation = -1 .. 2 | rotation + 1 = 0..3
#######
ROTATE_IN_Y:
  addi sp, sp, -16
  sw ra, 0(sp)
  sw a0, 4(sp)
  fsw fa0, 8(sp)
  fsw fs0, 12(sp)

  # Calling sin angle
  jal SIN
  fmv.s fs0, fa0

  # Retrieving fa0 t0 call COS
  flw fa0, 8(sp)
  jal COS

  # Retrieving a0
  lw a0, 4(sp)

  # Doing rotation. {a0 = cos, fs0 = sin}
  flw ft0, VECTOR3_F_X(a0)
  flw ft1, VECTOR3_F_Z(a0)

  fmul.s ft2, ft0, fa0 # x * cos
  fmul.s ft3, ft0, fs0 # x * sin

  fmul.s ft4, ft1, fa0 # z * cos
  fmul.s ft5, ft1, fs0 # z * sin

  fmv.s ft0, ft2
  fadd.s ft0, ft2, ft5 # x*cos + z*sin
  fsub.s ft1, ft4, ft3 # z*cos - x*sin

  fsw ft0, VECTOR3_F_X(a0)
  fsw ft1, VECTOR3_F_Z(a0)

  lw ra, 0(sp)
  flw fs0, 12(sp)
  addi sp, sp, 16
  ret

#########################################################
# a0 = triangule
#########################################################
# a0 = ly
# a1 = hy
#########################################################
GET_VERT_BOUND:
  lw t0, TRIANGLE_W_V1(a0)
  lw t1, TRIANGLE_W_V3(a0)

  flw ft0, VECTOR2_F_Y(t0)
  flw ft1, VECTOR2_F_Y(t1)

  fcvt.w.s a0, ft0
  fcvt.w.s a1, ft1

  bge a0, zero, get_vert_bound_no_negative_l
  mv a0, zero
get_vert_bound_no_negative_l:
  li t0, SCREEN_HEIGHT
  bge a0, t0, get_vert_bound_error

  blt a1, t0, get_vert_bound_no_bigger_h
  li a1, SCREEN_HEIGHT
  addi a1, a1, -1
get_vert_bound_no_bigger_h:
  blt a1, zero, get_vert_bound_error
  ret

get_vert_bound_error:
  li a0, 1
  li a1, 0
  ret

#####################
# a0 = triangle
# a1 = y
#####################
GET_HORZ_BOUND:

	lw t0, TRIANGLE_W_V1(a0)
	lw t1, TRIANGLE_W_V2(a0)
	lw t2, TRIANGLE_W_V3(a0)

	flw ft5, VECTOR2_F_X(t0)
	flw ft6, VECTOR2_F_X(t1)
	flw ft7, VECTOR2_F_X(t2)
	flw ft8, VECTOR2_F_Y(t0)
	flw ft9, VECTOR2_F_Y(t1)
	flw ft10, VECTOR2_F_Y(t2)

	# fa1 = y
	fcvt.s.w fa1, a1

	# fa2, fa3 = xStart xEnd

	# if v0.y == v1.y
	feq.s t0, ft8, ft9 
	beq t0, zero, get_horz_bound_notif1

	# get(v0, v2)
	GET_LINE_X(ft5, ft7, ft8, ft10)
	fmv.s fa2, fa0

	# get(v1,v2)
	GET_LINE_X(ft6, ft7, ft9, ft10)
	fmv.s fa3, fa0

	j get_horz_bound_end

get_horz_bound_notif1:
	# if v1.y == v2.y 
	feq.s t0, ft9, ft10
	beq t0, zero, get_horz_bound_notif2

	# get(v0, v1)
	GET_LINE_X(ft5, ft6, ft8, ft9)
	fmv.s fa2, fa0

	# get(v0,v2)
	GET_LINE_X(ft5, ft7, ft8, ft10)
	fmv.s fa3, fa0

	j get_horz_bound_end
get_horz_bound_notif2:
	# if y < v1.y
	flt.s t0, fa1, ft9
	beq t0, zero, get_horz_bound_notif3

	# get(v0, v1)
	GET_LINE_X(ft5, ft6, ft8, ft9)
	fmv.s fa2, fa0

	# get(v0,v2)
	GET_LINE_X(ft5, ft7, ft8, ft10)
	fmv.s fa3, fa0

	j get_horz_bound_end
get_horz_bound_notif3:
	# get(v1, v2)
	GET_LINE_X(ft6, ft7, ft9, ft10)
	fmv.s fa2, fa0

	# get(v0,v2)
	GET_LINE_X(ft5, ft7, ft8, ft10)
	fmv.s fa3, fa0

	j get_horz_bound_end

get_horz_bound_end:
	# fa0 = xStart
	fmin.s fa0, fa2, fa3
	# fa1 = xEnd
	fmax.s fa1, fa2, fa3

	# ft0 = SCREEN_WIDTH
	li t0, SCREEN_WIDTH
	addi t0, t0, -1
	fcvt.s.w ft0, t0

	# ft2 = 0.0
	fmv.s.x ft2, zero

	# bound xStart to screen
	fmax.s fa0, fa0, ft2
	fmin.s fa0, fa0, ft0

	# bound xEnd to screen
	fmin.s fa1, fa1, ft0
	fmax.s fa1, fa1, ft2

	fcvt.w.s a0, fa0
	fcvt.w.s a1, fa1

	ret

#########################################################
# a0 = x1
# a1 = y1
# a2 = x2
# a3 = y2
# a4 = x3
# a5 = y3
# a6 = xp
# a7 = yp
#########################################################
# a0 = u1
# a1 = u2
# a2 = u3
#########################################################
BARYCENTRIC:
  sub     t1, a0, a4
  sub     a3, a3, a5
  mul     t0, a3, t1
  sub     a0, a2, a4
  sub     a1, a5, a1
  mul     a0, a1, a0
  add     a0, a0, t0
  fcvt.s.w        ft0, a0
  sub     a0, a6, a4
  mul     a3, a0, a3
  sub     a2, a4, a2
  sub     a4, a7, a5
  mul     a2, a4, a2
  add     a2, a2, a3
  fcvt.s.w        ft1, a2
  fdiv.s  fa0, ft1, ft0
  mul     a0, a0, a1
  mul     a1, a4, t1
  add     a0, a0, a1
  fcvt.s.w        ft2, a0
  fdiv.s  fa1, ft2, ft0
  
  li t0, 1
  fcvt.s.w fa2, t0
  fsub.s fa2, fa2, fa0
  fsub.s fa2, fa2, fa1
  ret


#########################################################
# a0 = col0
# a1 = col1
# a2 = col2
#########################################################
MIX_COLORS:
	andi t0, a0, 7
	andi t1, a1, 7
	andi t2, a2, 7
	add t0, t0, t1
	add t0, t0, t2
	li t1, 3
	div t0, t0, t1

	andi t1, a0, 56
	srli t1, t1, 3
	andi t2, a1, 56
	srli t2, t2, 3
	andi t3, a2, 56
	srli t3, t3, 3
	add t1, t1, t2
	add t1, t1, t3
	li t2, 3
	div t1, t1, t2
	slli t1, t1, 3

	andi t2, a0, 0xc0
	srli t2, t2, 6
	andi t3, a1, 0xc0
	srli t3, t3, 6
	andi t4, a2, 0xc0
	srli t4, t4, 6
	add t2, t2, t3
	add t2, t2, t4
	li t3, 3
	div t2, t2, t3
	slli t2, t2, 6

	add a0, t0, t1
	add a0, a0, t2

	ret

