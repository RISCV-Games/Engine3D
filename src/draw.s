DRAW_BACKGROUND:
	GET_BUFFER_TO_DRAW(t0)
	li t1, NUMBER_OF_SCREEN_PIXELS
	add t1, t0, t1

loop_draw_back_ground:
	bge t0, t1, end_draw_back_ground
	sw a0, 0(t0)
	addi t0, t0, 4
	j loop_draw_back_ground

end_draw_back_ground:
	ret


#########################################################
# a0 = color
# a1 = x
# a2 = y
#########################################################
DRAW_SCALLED_PIXEL:
  li t1, SCREEN_WIDTH
  mul t1, t1, a2
  add t1, t1, a1
  slli t1, t1, 1 # t1 = (y * SCREEN_WIDTH + x) * 2

  GET_BUFFER_TO_DRAW(t3)
  add t3, t3, t1

  # Drawing 4
  sb a0, 0(t3)
  sb a0, 1(t3)
  sb a0, 2(t3)
  sb a0, 3(t3)
  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sb a0, 0(t3)
  sb a0, 1(t3)
  sb a0, 2(t3)
  sb a0, 3(t3)
  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sb a0, 0(t3)
  sb a0, 1(t3)
  sb a0, 2(t3)
  sb a0, 3(t3)
  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sb a0, 0(t3)
  sb a0, 1(t3)
  sb a0, 2(t3)
  sb a0, 3(t3)

  ret

  # Drawing 4
  sw t0, 0(t3)
  addi t0, t0, 4
  sw t0, 0(t3)
  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sw t0, 0(t3)
  addi t0, t0, 4
  sw t0, 0(t3)
  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sw t0, 0(t3)
  addi t0, t0, 4
  sw t0, 0(t3)
  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sw t0, 0(t3)
  addi t0, t0, 4
  sw t0, 0(t3)

  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sw t0, 0(t3)
  addi t0, t0, 4
  sw t0, 0(t3)
  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sw t0, 0(t3)
  addi t0, t0, 4
  sw t0, 0(t3)
  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sw t0, 0(t3)
  addi t0, t0, 4
  sw t0, 0(t3)
  # Drawing next 4
  addi t3, t3, SCREEN_WIDTH
  sw t0, 0(t3)
  addi t0, t0, 4
  sw t0, 0(t3)


  ret
