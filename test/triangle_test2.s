.data
vector: .word 0 0 0
v0: .float 15, 15
v1: .float 40, 200
v2: .float 210, 200

.text
main:
	la t0, vector
	la t1, v0
	la t2, v1
	la t3, v2
	sw t1, 0(t0)
	sw t2, 4(t0)
	sw t3, 8(t0)

	la a0, vector
	la a2, v0
	la a3, v1
	la a1, v2
	jal MAKE_TRIANGLE

	# s0 = y = 0
	li s0, 15

main_loop:
	li t0, 200
	bgt s0, t0, main_exit

	la a0, vector
	mv a1, s0
	jal GET_HORZ_BOUND
	mv s1, a1

main_loop_2:
	bgt a0, s1, main_loop2_break

	PIXEL(t0, a0, s0)
	li t1, 255
	sb t1, 0(t0)

	addi a0, a0,1
	j main_loop_2

main_loop2_break:
	addi s0, s0, 1
	j main_loop


main_exit:
j main_exit
	li a7, 10
	ecall