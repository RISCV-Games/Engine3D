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

.data
.include "../data/triangle.data"

.eqv NUMBER_OF_PIXELS 0x12C00
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
  # Clear background
  li a0, 0xFFFFFFFF
  jal DRAW_BACKGROUND

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

  # Rotating V1
  la a0, VECTOR3s
  csrr t0, time
  li t1, 1000
  fcvt.s.w fa0, t0
  fcvt.s.w ft0, t1
  fdiv.s fa0, fa0, ft0
  jal ROTATE_IN_Y

  # Rotating V2
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  csrr t0, time
  li t1, 1000
  fcvt.s.w fa0, t0
  fcvt.s.w ft0, t1
  fdiv.s fa0, fa0, ft0
  jal ROTATE_IN_Y

  # Rotating V3
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a0, a0, VECTOR3_BYTE_SIZE
  csrr t0, time
  li t1, 1000
  fcvt.s.w fa0, t0
  fcvt.s.w ft0, t1
  fdiv.s fa0, fa0, ft0
  jal ROTATE_IN_Y

  # Translating V1
  la a0, VECTOR3s
  li t0, 0
  fcvt.s.w fa0, t0# fa0 = 0
  fcvt.s.w fa1, t0# fa1 = 0
  li t0, 1
  fcvt.s.w fa2, t0# fa2 = 1
  jal TRANSLATE

  # Translating V2
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  li t0, 0
  fcvt.s.w fa0, t0# fa0 = 0
  fcvt.s.w fa1, t0# fa1 = 0
  li t0, 1
  fcvt.s.w fa2, t0# fa2 = 1
  jal TRANSLATE

  # Translating V3
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a0, a0, VECTOR3_BYTE_SIZE
  li t0, 0
  fcvt.s.w fa0, t0# fa0 = 0
  fcvt.s.w fa1, t0# fa1 = 0
  li t0, 1
  fcvt.s.w fa2, t0# fa2 = 1
  jal TRANSLATE

  # Projecting to 2D
  la a0, VECTOR3s
  la a1, VECTOR2s
  jal PROJECT_3D_2D

  la a0, VECTOR3s
  la a1, VECTOR2s
  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a1, a1, VECTOR2_BYTE_SIZE
  jal PROJECT_3D_2D

  la a0, VECTOR3s
  la a1, VECTOR2s
  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a1, a1, VECTOR2_BYTE_SIZE
  addi a1, a1, VECTOR2_BYTE_SIZE
  jal PROJECT_3D_2D

  # Projecting to Screen Word
  la a0, VECTOR2s
  jal PROJECT_SCREEN_WORD

  la a0, VECTOR2s
  addi a0, a0, VECTOR2_BYTE_SIZE
  jal PROJECT_SCREEN_WORD

  la a0, VECTOR2s
  addi a0, a0, VECTOR2_BYTE_SIZE
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
  li a7, 5
  ecall
  li a7, 10
  ecall
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
  ret
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

GET_HORZ_BOUND:
  li a0, 10
  li a1, 60
  ret

#############################
# a0 = color
#############################
DRAW_BACKGROUND:
	li t0, SCREEN_BUFFER_ADDRESS
	li t1, NUMBER_OF_PIXELS
	add t1, t0, t1

loop_draw_back_ground:
	bge t0, t1, end_draw_back_ground
	sw a0, 0(t0)
	addi t0, t0, 4
	j loop_draw_back_ground

end_draw_back_ground:
	ret

.include "../src/barycentric.s"
.include "../src/math.s"
