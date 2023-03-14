.include "../src/consts.s"
.include "../src/macros.s"

.data
.include "../src/data.s"
#.include "../data/triangle.data"
#.include "../data/humanoid.data"
#.include "../data/triangle2.data"
#.include "../data/cube.data"
#.include "../data/cup.data"
.include "../data/tree.data"

.align 2
VECTOR3s:
  .space VECTOR3s_BYTE_SIZE

.align 2
VECTOR2s:
  .space VECTOR2s_BYTE_SIZE

TRIANGLE:
  .space TRIANGLE_BYTE_SIZE

.align 2
ZBUFFER:
  .space ZBUFFER_SIZE

.text
  jal INIT_VIDEO
  li s6, 0
MAIN:
  li t0, 0
  li t2, MAX_FLOAT
  fmv.s.x ft0, t2
  li t1, ZBUFFER_SIZE
  la t3, ZBUFFER

main_clear_zbuffer:
  bge t0, t1, main_clear_zbuffer_end
  fsw ft0, 0(t3)
  addi t0, t0, 4
  addi t3, t3, 4
  j main_clear_zbuffer

main_clear_zbuffer_end:
  # Clear background
  #li a0, 0xf4f4f4f4
  li a0, 0
  jal DRAW_BACKGROUND

  # Loop mesh
  la t0, MESH_SIZE
  lw s1, 0(t0)
  li s0, 0

main_mesh_loop:
  bge s0, s1, main_mesh_loop_end

  # Load FACE
  li t0, 12
  mul t0, t0, s0
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
  li t1, 1000
  fcvt.s.w fa0, s6
  fcvt.s.w ft0, t1
  fdiv.s fa0, fa0, ft0
  jal ROTATE_IN_Y

  # Rotating V2
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  li t1, 1000
  fcvt.s.w fa0, s6
  fcvt.s.w ft0, t1
  fdiv.s fa0, fa0, ft0
  jal ROTATE_IN_Y

  # Rotating V3
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a0, a0, VECTOR3_BYTE_SIZE
  li t1, 1000
  fcvt.s.w fa0, s6
  fcvt.s.w ft0, t1
  fdiv.s fa0, fa0, ft0
  jal ROTATE_IN_Y

  # Translating V1
  la a0, VECTOR3s
  fcvt.s.w fa0, zero# fa0 = 0
  fcvt.s.w fa1, zero# fa1 = 0
  li t0, HALF_S 
  fmv.s.x fa2, t0
  li t0, 1
  fcvt.s.w ft0, t0
  fadd.s fa2, fa2, ft0 # fa2 = 1
  jal TRANSLATE

  # Translating V2
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  fcvt.s.w fa0, zero# fa0 = 0
  fcvt.s.w fa1, zero# fa1 = 0
  li t0, HALF_S
  fmv.s.x fa2, t0
  li t0, 1
  fcvt.s.w ft0, t0
  fadd.s fa2, fa2, ft0 # fa2 = 1
  jal TRANSLATE

  # Translating V3
  la a0, VECTOR3s
  addi a0, a0, VECTOR3_BYTE_SIZE
  addi a0, a0, VECTOR3_BYTE_SIZE
  fcvt.s.w fa0, zero# fa0 = 0
  fcvt.s.w fa1, zero# fa1 = 0
  li t0, HALF_S
  fmv.s.x fa2, t0
  li t0, 1
  fcvt.s.w ft0, t0
  fadd.s fa2, fa2, ft0 # fa2 = 1
  jal TRANSLATE

  # Saving Zss
  la t0, VECTOR3s
  flw fs9, VECTOR3_F_Z(t0)
  addi t0, t0, VECTOR3_BYTE_SIZE
  flw fs10, VECTOR3_F_Z(t0)
  addi t0, t0, VECTOR3_BYTE_SIZE
  flw fs11, VECTOR3_F_Z(t0)

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

  # Making triangle
  la a0, TRIANGLE
  la a1, VECTOR2s
  addi a2, a1, VECTOR2_BYTE_SIZE
  addi a3, a2, VECTOR2_BYTE_SIZE
  li a4, RED_COLOR
  li a5, GREEN_COLOR
  li a6, BLUE_COLOR
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

	la a0, TRIANGLE
	mv a1, s4
	mv a2, s2
	jal TRIANGLE_BARYCENTRIC # Returns a0 = is_point_inside_triangle ,fa0 = u1, fa1 = u2, fa2 = u3
  beq a0, zero, main_no_draw
  fmv.s fs0, fa0
  fmv.s fs1, fa1
  fmv.s fs2, fa2

  # Doing Zbuffer calculation
  # Defining near
  li t1, NEAR
  fmv.s.x ft6, t1

  ## Defining far
  li t1, FAR
  fmv.s.x ft7, t1

  # Inverting
  li t0, 1
  fcvt.s.w ft3, t0

  # getting 1/z
  fdiv.s ft0, ft3, fs9
  fdiv.s ft1, ft3, fs10
  fdiv.s ft2, ft3, fs11

  # multiplying u
  fmul.s ft0, ft0, fs0
  fmul.s ft1, ft1, fs1
  fmul.s ft2, ft2, fs2

  # Adding
  fadd.s ft4, ft0, ft1
  fadd.s ft4, ft4, ft2 # ft4 = 1/z

  # Inverting back
  fdiv.s ft5, ft3, ft4 # ft5 = z

  ZBUFFER_PIXEL(t0, s4, s2)
  flw ft1, 0(t0) # ft1 = zbuffer z

  fle.s t1, ft1, ft5 # z < zbuffer
  flt.s t2, ft5, ft6 # z > near
  flt.s t3, ft7, ft5 # z < far
  or t1, t1, t2
  or t1, t1, t3
  bgt t1, zero, main_no_draw
  fsw ft5 0(t0)
  fmv.s fs3, ft5

  # Drawing
  fmv.s fa0, fs0
  fmv.s fa1, fs1
  fmv.s fa2, fs2
  la t0, TRIANGLE
  lb a0, TRIANGLE_B_COLOR0(t0)
  lb a1, TRIANGLE_B_COLOR1(t0)
  lb a2, TRIANGLE_B_COLOR2(t0)
  jal MIX_COLOR3_B # Returns a0 = color
  fmv.s fa0, fs3
  jal SHADE_COLOR_Z
  mv a1, s4
  mv a2, s2
  jal DRAW_SCALLED_PIXEL
	
main_no_draw:
	addi s4, s4, 1
	j main_horz_loop

main_horz_loop_end:
  addi s2, s2 ,1
  j main_vert_loop

main_vert_loop_end:
  addi s0, s0, 1
  j main_mesh_loop

main_mesh_loop_end:
  #li a7, 5
  #ecall
  #li a7, 10
  #ecall

  jal SWAP_FRAMES
  addi s6, s6, 10

  j MAIN

.include "../src/math.s"
.include "../src/draw.s"
.include "../src/graphics.s"
.include "../src/video.s"
