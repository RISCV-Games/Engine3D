.include "../src/consts.s"
.macro MAKE_VECTOR3(%addr, %x, %y, %z)
  fsw %x, VECTOR3_F_X(%addr)
  fsw %y, VECTOR3_F_Y(%addr)
  fsw %z, VECTOR3_F_Z(%addr)
.end_macro

.macro PIXEL(%reg, %x, %y)
  li %reg, SCREEN_WIDTH  
  mul %reg, %reg, %y
  add %reg, %reg, %x
  li t6, SCREEN_BUFFER_ADDRESS
  add %reg, %reg, t6
.end_macro

.macro SWAP(%temp, %a, %b)
  mv %temp, %a
  mv %a, %b
  mv %b, %temp
.end_macro

.macro MAKE_VECTOR2(%addr, %x, %y)
  fsw %x, VECTOR2_F_X(%addr)
  fsw %y, VECTOR2_F_Y(%addr)
.end_macro

.macro GET_LINE_X(%x0, %x1, %y0, %y1)
	fmv.s ft0, %x0
	fmv.s ft1, %x1
	fmv.s ft2, %y0
	fmv.s ft3, %y1

	# fa0 = (ft0*(fa1-ft3) + ft1*(ft2-fa1)) / (u-v)
	fsub.s fa0, fa1, ft3 
	fmul.s fa0, fa0, ft0
	fsub.s ft4, ft2, fa1
	fmul.s ft4, ft4, ft1
	fadd.s fa0, fa0, ft4
	fsub.s ft4, ft2, ft3
	fdiv.s fa0, fa0, ft4
.end_macro

.data
.include "../data/humanoid.data"

# Vectors 3
.eqv VECTOR3_BYTE_SIZE 12
.eqv VECTOR3_F_X 0
.eqv VECTOR3_F_Y 4
.eqv VECTOR3_F_Z 8
.eqv VECTOR3s_BYTE_SIZE 36 # 12 * 3
.align 2
VECTOR3s:
  .space VECTOR3s_BYTE_SIZE

# Vectors 2
.eqv VECTOR2_BYTE_SIZE 8
.eqv VECTOR2_F_X 0
.eqv VECTOR2_F_Y 4
.eqv VECTOR2s_BYTE_SIZE 24 # 8 * 3
.align 2
VECTOR2s:
  .space VECTOR2s_BYTE_SIZE

# Triangle
.eqv TRIANGLE_BYTE_SIZE 16
.eqv TRIANGLE_W_V1 0
.eqv TRIANGLE_W_V2 4
.eqv TRIANGLE_W_V3 8
.eqv TRIANGLE_B_ORDER0 12
.eqv TRIANGLE_B_ORDER1 13
.eqv TRIANGLE_B_ORDER2 14

TRIANGLE:
  .space TRIANGLE_BYTE_SIZE

.text

MAIN:
  # Loop mesh
  la t0, MESH_SIZE
  lw s0, 0(t0)
  li s1, 0

main_mesh_loop:
  bge s1, s0, main_mesh_loop_end

  # Load FACE
  li t0, 12
  mul t0, t0, s1
  la t1, MESH_FACE
  add t0, t0, t1

  lw t1, 0(t0) # v1*
  lw t2, 4(t0) # v2*
  lw t3, 8(t0) # v3*
  la t0, MESH_VERT
  la t4, VECTOR3s

  # Load v1
  li t5, 12
  mul t1, t1, t5
  add t1, t1, t0

  flw ft0, 0(t1)
  flw ft1, 4(t1)
  flw ft2, 8(t1)
  MAKE_VECTOR3(t4, ft0, ft1, ft2)
  addi t4, t4, VECTOR3_BYTE_SIZE

  # Load v2
  li t5, 12
  mul t2, t2, t5
  add t2, t2, t0

  flw ft0, 0(t2)
  flw ft1, 4(t2)
  flw ft2, 8(t2)
  MAKE_VECTOR3(t4, ft0, ft1, ft2)
  addi t4, t4, VECTOR3_BYTE_SIZE

  # Load v3
  li t5, 12
  mul t3, t3, t5
  add t3, t3, t0

  flw ft0, 0(t3)
  flw ft1, 4(t3)
  flw ft2, 8(t3)
  MAKE_VECTOR3(t4, ft0, ft1, ft2)

  # Projecting to 2D
  la a0, VECTOR3s
  la a1, VECTOR2s
  jal PROJECT_3D_2D

  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a1, a1, VECTOR2_BYTE_SIZE
  jal PROJECT_3D_2D

  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a1, a1, VECTOR2_BYTE_SIZE
  jal PROJECT_3D_2D

  # Projecting to Screen Word
  la a0, VECTOR2s
  jal PROJECT_SCREEN_WORD

  addi a0, a0, VECTOR2_BYTE_SIZE
  jal PROJECT_SCREEN_WORD

  addi a0, a0, VECTOR2_BYTE_SIZE
  jal PROJECT_SCREEN_WORD

  la a0, TRIANGLE
  la a1, VECTOR2s
  addi a2, a1, VECTOR2_BYTE_SIZE
  addi a3, a2, VECTOR2_BYTE_SIZE
  jal MAKE_TRIANGLE

  la a0, TRIANGLE
  jal GET_VERT_BOUND
  mv s2, a0
  mv s3, a1

main_vert_loop:
  bgt s2, s3, main_vert_loop_end

  la a0, TRIANGLE
  mv a1, s2
  call GET_HORZ_BOUND
  mv s4, a0
  mv s5, a1

  main_horz_loop:
    bgt s4, s5, main_horz_loop_end

    # la a0, TRIANGLE
    # mv a1, s4
    # mv a2, s2
    # jal TRIANGLE_BARYCENTRIC
    PIXEL(t0, s4, s2)
    li t1, 0x2828
    sb t1, 0(t0)
    
    addi s4, s4, 1
    j main_horz_loop

main_horz_loop_end:
  addi s2, s2 ,1
  j main_vert_loop

main_vert_loop_end:
  addi s1, s1, 1
  j main_mesh_loop

main_mesh_loop_end:
  j MAIN

#########################################################
# a0 = Vector3_SRC
# a1 = Vector2_DEST
#########################################################
PROJECT_3D_2D:
  flw ft0, VECTOR3_F_X(a0)
  flw ft1, VECTOR3_F_Y(a0)
  flw ft2, VECTOR3_F_Z(a0)

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

  lw t4, VECTOR2_F_Y(a1)
  lw t5, VECTOR2_F_Y(a3)
  bge t5, t4, make_triangle_no_swap_13

  # Swap 1-3
  SWAP(t4, a1, a3)
  SWAP(t4, t1, t3)

make_triangle_no_swap_13:
  lw t4, VECTOR2_F_Y(a2)
  lw t5, VECTOR2_F_Y(a3)
  bge t5, t4, make_triangle_no_swap_23

  # Swap 2 - 3
  SWAP(t4, a2, a3)
  SWAP(t4, t2, t3)

make_triangle_no_swap_23:
  lw t4, VECTOR2_F_Y(a1)
  lw t5, VECTOR2_F_Y(a2)
  bge t5, t4, make_triangle_no_swap_12
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

# pseudocode for GET_HORZ_BOUND function
# if v0.y == v1.y
# 	xStart = get(v0, v2)
# 	xEnd = get(v1,v2)
# else if v1.y == v2.y
# 	xStart = get(v0, v1)
# 	xEnd = get(v0,v2)
# else if y < v1.y
# 	xStart = get(v0, v1)
# 	xEnd = get(v0, v2)
# else 
# 	xStart = get(v1, v2)
# 	xEnd = get(v0, v2)
#
# if xStart > xEnd
# 	swap(xstart, xEnd)
#
# xStart = min(max(xStart, 0), width)
# xEnd = max(min(xEnd, width), 0)



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

.include "../src/barycentric.s"
