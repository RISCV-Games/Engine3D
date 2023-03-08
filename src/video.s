#################################################
#	Organiza os frames do buffer de video         #
#################################################
INIT_VIDEO:
	# Setting current view frame
	li t0, CURRENT_DISPLAY_FRAME_ADRESS
	# Force start on frame 0
	sw zero,0(t0)

	# Setting current draw frame
	la t0, FRAME_TO_DRAW
	li t1, 1
	sb t1, 0(t0)

	ret

#########################################################
#	Troca o frame desenhado e o frame que esta sendo visto#
#########################################################
SWAP_FRAMES:
	# Swap current view frame
	li t0, CURRENT_DISPLAY_FRAME_ADRESS 
	lw t1, 0(t0)
	xori t2,t1,1
	sw t2,0(t0)

	# Swap current draw frame
	la t0, FRAME_TO_DRAW
	sb t1, 0(t0)
	
	ret
