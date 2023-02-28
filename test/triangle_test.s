.include "../src/consts.s"

.data
v1: .float 5 5
v2: .float 200 150
v3: .float 310 150

.text

li a0, 0
la a1, v1
la a2, v2
la a3, v3
call FLAT_BOTTOM_TRIANGLE



# Exit
li a7, 10
ecall



.include "../src/triangle.s"