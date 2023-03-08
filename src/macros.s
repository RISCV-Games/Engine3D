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