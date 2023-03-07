.include "../src/consts.s"
.macro MAKE_VECTOR3(%addr, %x, %y, %z)
  fsw %x, VECTOR3_F_X(%addr)
  fsw %y, VECTOR3_F_Y(%addr)
  fsw %z, VECTOR3_F_Z(%addr)
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
  ret

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

  addi s1, s1, 1
  j main_mesh_loop

  la a0, TRIANGLE
  la a1, V1
  la a2, V2
  la a3, V3
  jal MAKE_TRIANGLE

  la a0, TRIANGLE
  call GET_VERT_BOUND
  mv s2, a0
  mv s3, a1

main_vert_loop:
  bgt s2, s3, main_mesh_loop_end

  la a0, TRIANGLE
  mv a1, s2
  call GET_HORZ_BOUND
  mv s4, a0
  mv s5, a1

  main_horz_loop:
    
    j main_horz_loop

  j main_vert_loop

main_mesh_loop_end:
  li a7, 10
  ecall


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

  fsw ft0, VECTOR2_F_X(a0)
  fsw ft1, VECTOR2_F_Y(a0)
  ret
