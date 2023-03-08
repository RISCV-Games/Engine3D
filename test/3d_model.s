.include "../src/consts.s"
.include "../src/macros.s"

.data
#.include "../data/triangle.data"
#.include "../data/humanoid.data"
.include "../data/triangle2.data"

.align 2
VECTOR3s:
  .space VECTOR3s_BYTE_SIZE

.align 2
VECTOR2s:
  .space VECTOR2s_BYTE_SIZE

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
  li t0, 3
  fcvt.s.w fa2, t0# fa2 = 1
  jal TRANSLATE

  # Translating V2
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  li t0, 0
  fcvt.s.w fa0, t0# fa0 = 0
  fcvt.s.w fa1, t0# fa1 = 0
  li t0, 3
  fcvt.s.w fa2, t0# fa2 = 1
  jal TRANSLATE

  # Translating V3
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a0, a0, VECTOR3_BYTE_SIZE
  li t0, 0
  fcvt.s.w fa0, t0# fa0 = 0
  fcvt.s.w fa1, t0# fa1 = 0
  li t0, 3
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
#   li a7, 5
#   ecall
#   li a7, 10
#   ecall
  j MAIN

.include "../src/math.s"
.include "../src/draw.s"
.include "../src/graphics.s"