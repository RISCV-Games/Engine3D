.include "../src/consts.s"

.data
v1: .float 5 5
v2: .float 200 5
v3: .float 310 150

TIME: .word 0
TIME_STRING: .string ": RENDER_TIME\n"

.text

Loop: 
  li a0, 0
  la a1, v1
  la a2, v2
  la a3, v3
  call FLAT_TOP_TRIANGLE

  csrr t0, cycle
  la t1, TIME
  lw t2, 0(t1)
  sub a0, t0, t2
  sw t0, 0(t1)

  li a7, 1
  ecall

  la a0, TIME_STRING
  li a7, 4
  ecall
  j Loop

# Exit
li a7, 10
ecall

.include "../src/triangle.s"
