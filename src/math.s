##########################################################
# Calculates sin x with a maximum error of about 0.00452.
##########################################################
# fa0 = x
##########################################################
SIN:
	# ft0 = 2 * pi
	li t0, TWO_PI_S
	fmv.s.x ft0, t0

	# x = x - 2*pi*round(x/(2*pi))
	fdiv.s ft1, fa0, ft0
	fcvt.w.s t0, ft1
	fcvt.s.w ft1, t0
	fmul.s ft1, ft1, ft0
	fsub.s fa0, fa0, ft1

	# ft1 = 0
	fmv.s.x ft1, zero

	# ft2 = xsign = if x < 0 then 1 else 0
	flt.s t0, fa0, ft1
	fcvt.s.w ft2, t0

	# x += 2*pi*xsign
	fmul.s ft2, ft2, ft0
	fadd.s fa0, fa0, ft2

	# ft2 = sign = if x-pi < 0 then 1 else 0
	li t0, PI_S
	fmv.s.x ft0, t0
	fsub.s ft2, fa0, ft0
	flt.s t0, ft1, ft2
	fcvt.s.w ft2, t0

	# x = x - sign * pi
	fmul.s ft4, ft0, ft2
	fsub.s fa0, fa0, ft4

	# sign = 1-2*sign
	fadd.s ft2, ft2, ft2
	li t0, 1
	fcvt.s.w ft5, t0
	fsub.s ft2, ft5, ft2

	# ft4 = pi/2
	li t0, HALF_PI_S
	fmv.s.x ft4, t0

	# ft3 = sign2
	fsub.s ft3, fa0, ft4
	flt.s t0, ft1, ft3
	fcvt.s.w ft3, t0

	# sign2 = 1-2*sign2
	fmul.s ft0, ft0, ft3
	fsub.s fa0, fa0, ft0
	fadd.s ft3, ft3, ft3
	fsub.s ft3, ft5, ft3

	# x = sign * sign2 * x
	fmul.s fa0, fa0, ft3
	fmul.s fa0, fa0, ft2

	# ft0 = x**2
	fmul.s ft0, fa0, fa0

	# ft2 = x-x**3/6
	fmul.s ft2, ft0, fa0
	li t0, 6
	fcvt.s.w ft1, t0
	fdiv.s ft2, ft2, ft1
	fsub.s ft2, fa0, ft2

	# ft1 = x**5/120
	fmul.s ft0, ft0, ft0
	fmul.s ft0, ft0, fa0
	li t0, 120
	fcvt.s.w ft1, t0
	fdiv.s ft1, ft0, ft1

	# fa0 = x - x**3/6 + x**5/120
	fadd.s fa0, ft2, ft1

	ret

##########################################################
# Calculates cos x with a maximum error of about 0.00452.
##########################################################
# fa0 = x
##########################################################
COS:
	li t0, HALF_PI_S
	fmv.s.x ft0, t0
	fsub.s fa0, ft0, fa0
	j SIN