.include "../src/consts.s"
.include "../src/macros.s"
.text
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 319
  li a4, 239
  li a5, 160
  li a6, 50
  li a7, 50

  call BARYCENTRIC
  li a7, 2
  ecall
  
  li a0, '\n'
  li a7, 11
  ecall

  fmv.s fa0, fa1
  li a7, 2
  ecall

  li a0, '\n'
  li a7, 11
  ecall

  fmv.s fa0, fa2
  li a7, 2
  ecall

  li a0, '\n'
  li a7, 11
  ecall

  li a7, 10
  ecall

.include "../src/graphics.s"
.include "../src/math.s"
