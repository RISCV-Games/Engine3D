#########################################################
# a0 = Vector3_SRC
# a1 = Vector2_DEST
#########################################################
PROJECT_3D_2D:
  flw ft0, VECTOR3_F_X(a0)
  flw ft1, VECTOR3_F_Y(a0)
  flw ft2, VECTOR3_F_Z(a0)

  fabs.s ft2, ft2

  li t0, EPSILON
  fmv.s.x ft4, t0
  fmax.s ft2, ft2, ft4

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

  li t0, DISPLAY_WIDTH
  li t1, DISPLAY_HEIGHT
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
# a4 = color1
# a5 = color2
# a6 = color3
#########################################################
MAKE_TRIANGLE:
  flw ft0, VECTOR2_F_Y(a1)
  flw ft1, VECTOR2_F_Y(a3)
  flt.s t4, ft0, ft1 
  bgt t4, zero, make_triangle_no_swap_13

  # Swap 1-3
  SWAP(t4, a1, a3)
  SWAP(t4, a4, a6)
  FSWAP(ft4, fs9, fs11)

make_triangle_no_swap_13:
  flw ft0, VECTOR2_F_Y(a2)
  flw ft1, VECTOR2_F_Y(a3)
  flt.s t4, ft0, ft1 
  bgt t4, zero, make_triangle_no_swap_23

  # Swap 2 - 3
  SWAP(t4, a2, a3)
  SWAP(t4, a5, a6)
  FSWAP(ft4, fs10, fs11)

make_triangle_no_swap_23:
  flw ft0, VECTOR2_F_Y(a1)
  flw ft1, VECTOR2_F_Y(a2)
  flt.s t4, ft0, ft1 
  bgt t4, zero, make_triangle_no_swap_12

  # Swap 1 2
  SWAP(t4, a1, a2)
  SWAP(t4, a4, a5)
  FSWAP(ft4, fs9, fs10)

make_triangle_no_swap_12:
  sw a1, TRIANGLE_W_V1(a0)
  sw a2, TRIANGLE_W_V2(a0)
  sw a3, TRIANGLE_W_V3(a0)
  sb a4, TRIANGLE_B_COLOR0(a0)
  sb a5, TRIANGLE_B_COLOR1(a0)
  sb a6, TRIANGLE_B_COLOR2(a0)
  ret

#########################################################
# a0 = triangule
# a1 = xp
# a2 = yp
#########################################################
TRIANGLE_BARYCENTRIC:
  mv a6, a1
  mv a7, a2

  lw t0, TRIANGLE_W_V1(a0)
  lw t1, TRIANGLE_W_V2(a0)
  lw t2, TRIANGLE_W_V3(a0)

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
# z = -1..1 y = -1..1| rotation = -1 .. 2 | rotation + 1 = 0..3
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
  li t0, DISPLAY_HEIGHT
  bge a0, t0, get_vert_bound_error

  blt a1, t0, get_vert_bound_no_bigger_h
  li a1, DISPLAY_HEIGHT
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
  # Normal Implementation
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
	li t0, DISPLAY_WIDTH
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
# a0 = is_point_inside_triangle?
# fa0 = u1
# fa1 = u2
# fa2 = u3
#########################################################
BARYCENTRIC:
  # Calculing expressions parts
  sub t0, a0, a4 # (x1 - x3)
  sub t1, a3, a5 # (y2 - y3)
  sub t2, a2, a4 # (x2 - x3)
  sub t3, a1, a5 # (y1 - y3)
  sub t4, a6, a4 # (xp - x3)
  sub t5, a7, a5 # (yp - y3)

  # Calculing det
  mul a0, t0, t1 # (x1-x3) (y2-y3)
  mul a1, t2, t3 # (x2-x3) (y1-y3)
  sub t6, a0, a1 # (x1-x3) (y2-y3) - (x2-x3) (y1-y3)
  fcvt.s.w ft0, t6 # ft0 = det

  li a0, -1
  # Calculing top u1
  mul a1, t1, t4 # (y2 - y3) (xp - x3)
  mul a2, t2, a0 # (x3 - x2)
  mul a2, a2, t5 # (x3 - x2) (yp - y3)
  add a2, a2, a1 # (x3 - x2) (yp - y3) + (y2 - y3) (xp - x3)
  fcvt.s.w fa0, a2 # fa0 = u1 * det

  # Calculing top u2
  mul a1, t3, a0 # (y3 - y1)
  mul a1, a1, t4 # (y3 - y1) * (xp - x3)
  mul a2, t0, t5 # (x1 - x3) * (yp - y3)
  add a2, a2, a1 # (x1 - x3) * (yp - y3) + (y3 - y1) * (xp - x3)
  fcvt.s.w fa1, a2 # fa1 = u2 * det

  # Dividing by det
  fdiv.s fa0, fa0, ft0
  fdiv.s fa1, fa1, ft0

  # Calculing u3
  li a0, 1
  fcvt.s.w fa2, a0
  fsub.s fa2, fa2, fa0
  fsub.s fa2, fa2, fa1 # u3 = 1 - u1 - u2

  # Check if point exists
  fcvt.s.w ft1, zero
  flt.s t0, fa0, ft1 # t0 = fa0 < zero
  flt.s t1, fa1, ft1 # t1 = fa1 < zero
  flt.s t2, fa2, ft1 # t2 = fa2 < zero
  feq.s t3, ft0, ft1 # t3 = det == zero

  or t0, t0, t1
  or t0, t0, t2
  or t0, t0, t3
  bgt t0, zero, barycentric_not_exist

  # Exists!
  li a0, 1
  ret

barycentric_not_exist:
  li a0, 0
  ret


#########################################################
# fa0 = u1
# fa1 = u2
# fa2 = u3
# a0 = color1
# a1 = color2
# a2 = color3
#########################################################
# a0 = color
#########################################################
MIX_COLOR3_B:
  # RED
  RED(t0, a0)
  RED(t1, a1)
  RED(t2, a2)

  fcvt.s.w ft0, t0
  fcvt.s.w ft1, t1
  fcvt.s.w ft2, t2

  fmul.s ft0, ft0, fa0
  fmul.s ft1, ft1, fa1
  fmul.s ft2, ft2, fa2
  
  fadd.s ft3, ft0, ft1
  fadd.s ft3, ft3, ft2

  li t0, 7
  fcvt.s.w ft0, t0
  fmin.s ft3, ft3, ft0

  # Green
  GREEN(t0, a0)
  GREEN(t1, a1)
  GREEN(t2, a2)

  fcvt.s.w ft0, t0
  fcvt.s.w ft1, t1
  fcvt.s.w ft2, t2

  fmul.s ft0, ft0, fa0
  fmul.s ft1, ft1, fa1
  fmul.s ft2, ft2, fa2
  
  fadd.s ft4, ft0, ft1
  fadd.s ft4, ft4, ft2

  li t0, 7
  fcvt.s.w ft0, t0
  fmin.s ft4, ft4, ft0

  # Blue
  BLUE(t0, a0)
  BLUE(t1, a1)
  BLUE(t2, a2)

  fcvt.s.w ft0, t0
  fcvt.s.w ft1, t1
  fcvt.s.w ft2, t2

  fmul.s ft0, ft0, fa0
  fmul.s ft1, ft1, fa1
  fmul.s ft2, ft2, fa2
  
  fadd.s ft5, ft0, ft1
  fadd.s ft5, ft5, ft2

  li t0, 3
  fcvt.s.w ft0, t0
  fmin.s ft5, ft5, ft0

  fcvt.w.s t3, ft3
  fcvt.w.s t4, ft4
  fcvt.w.s t5, ft5

  RGB(a0, t3, t4, t5)

  li t0, TRANSP_COLOR
  bne a0, t0, mix_color3_is_not_transp

  li a0, 7
mix_color3_is_not_transp:
  ret

#########################################################
# a0 = col0
# a1 = col1
# a2 = col2
#########################################################
MIX_COLOR3_M:
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

#################################
# a0 = color
# fa0 = z
#################################
SHADE_COLOR_Z:
	li t0, 1
	fcvt.s.w ft0, t0
	fmax.s fa0, fa0, ft0

	RED(t0, a0)
	GREEN(t1, a0)
	BLUE(t2, a0)

	fcvt.s.w ft0, t0
	fcvt.s.w ft1, t1
	fcvt.s.w ft2, t2

	fdiv.s ft0, ft0, fa0 
	fdiv.s ft1, ft1, fa0 
	fdiv.s ft2, ft2, fa0 

	fcvt.w.s t0, ft0
	fcvt.w.s t1, ft1
	fcvt.w.s t2, ft2

	RGB(a0, t0, t1, t2)

	ret
