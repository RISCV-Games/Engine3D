#############################
# a0 = color
#############################
DRAW_BACKGROUND:
	li t0, SCREEN_BUFFER_ADDRESS
	li t1, NUMBER_OF_PIXELS
	add t1, t0, t1

loop_draw_back_ground:
	bge t0, t1, end_draw_back_ground
	sw a0, 0(t0)
	addi t0, t0, 4
	j loop_draw_back_ground

end_draw_back_ground:
	ret