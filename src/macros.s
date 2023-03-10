### Color Macros #####
.macro RED(%dest, %src)
  andi %dest, %src, 0x007
.end_macro

.macro GREEN(%dest, %src)
  andi %dest, %src,  0x038
  srli %dest, %dest, 3
.end_macro

.macro BLUE(%dest, %src)
  andi %dest, %src, 0x0C0
  srli %dest, %dest, 6
.end_macro

.macro RGB(%dest, %r, %g, %b)
  li %dest, 0
  or %dest, %dest, %b
  slli %dest, %dest, 3
  or %dest, %dest, %g
  slli %dest, %dest, 3
  or %dest, %dest, %r
.end_macro

########## Put the buffer to draw on register #########
.macro GET_BUFFER_TO_DRAW(%reg)
	addi sp, sp, -4
	sw s11, 0(sp)

	la %reg, FRAME_TO_DRAW
	lb %reg, 0(%reg)
	slli %reg, %reg, 20
	li s11, BUFFER_ADRESS
	add %reg, s11, %reg

	lw s11, 0(sp)
	addi sp, sp, 4
.end_macro

.macro MAKE_VECTOR3(%addr, %x, %y, %z)
  fsw %x, VECTOR3_F_X(%addr)
  fsw %y, VECTOR3_F_Y(%addr)
  fsw %z, VECTOR3_F_Z(%addr)
.end_macro

.macro PIXEL(%reg, %x, %y)
  addi sp, sp, -4
  sw t6, 0(sp)

  li %reg, SCREEN_WIDTH  
  mul %reg, %reg, %y
  add %reg, %reg, %x
  GET_BUFFER_TO_DRAW(t6)
  add %reg, %reg, t6

  lw t6, 0(sp)
  addi sp, sp, 4
.end_macro

.macro ZBUFFER_PIXEL(%reg, %x, %y)
  addi sp, sp, -4
  sw t6, 0(sp)

  li %reg, DISPLAY_WIDTH  
  mul %reg, %reg, %y
  add %reg, %reg, %x
  slli %reg, %reg, 2
  la t6, ZBUFFER
  add %reg, %reg, t6

  lw t6, 0(sp)
  addi sp, sp, 4
.end_macro

.macro SWAP(%temp, %a, %b)
  mv %temp, %a
  mv %a, %b
  mv %b, %temp
.end_macro

.macro FSWAP(%temp, %a, %b)
  fmv.s %temp, %a
  fmv.s %a, %b
  fmv.s %b, %temp
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
