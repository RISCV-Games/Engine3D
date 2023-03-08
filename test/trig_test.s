.include "../src/consts.s"
.text

	li t0, HALF_S
	fmv.s.x fs0, t0
	li t0, -20
	fcvt.s.w fs1, t0

	li s0, 0

loop:
	li t0, 80
	bge s0, t0, exit

	fmv.s fa0, fs1
	jal COS

	li a7, 2
	ecall

	li a7, 11
	li a0, '\n'
	ecall

	fadd.s fs1, fs1, fs0
	addi s0, s0, 1
	j loop

exit:
	li a7, 10
	ecall

.include "../src/math.s"