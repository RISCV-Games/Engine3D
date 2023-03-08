import math

def calcSin(x : float) -> float:
	# 0 <= x < 2pi
	x = x - 2*math.pi * math.floor(x/(2*math.pi))

	# 0 <= x <= pi
	sign = 1 if 0 < x-math.pi else 0
	x = x-sign*math.pi
	sign = 1 - sign * 2
	
	# 0 <= x <= pi/2
	sign2 = 1 if 0 < x-math.pi/2 else 0
	x = x - math.pi * sign2
	sign2 = 1-sign2*2
	x = x * sign2

	return sign * (x - x**3/6 + x**5/120)

interval=200
npoints = 10000
worst=-1

for i in range(npoints):
	x = i/(npoints-1) * interval * 2 - interval
	worst = max(worst, abs(math.sin(x) - calcSin(x)))

print(worst)