#########################################################
# a0 = x1
# a1 = y1
# a2 = x2
# a3 = y2
# a4 = x3
# a5 = y3
# a6 = xp
# a7 = yp
#########################################################
# float det = (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3);
# u1 = ((y2 - y3) * (xp - x3) + (x3 - x2) * (yp - y3))/det;
# u2 = ((y3 - y1) * (xp - x3) + (x1 - x3) * (yp - y3))/det;
BARYCENTRIC:
  sub     t1, a0, a4
  sub     a3, a3, a5
  mul     t0, a3, t1
  sub     a0, a2, a4
  sub     a1, a5, a1
  mul     a0, a1, a0
  add     a0, a0, t0
  fcvt.s.w        ft0, a0
  sub     a0, a6, a4
  mul     a3, a0, a3
  sub     a2, a4, a2
  sub     a4, a7, a5
  mul     a2, a4, a2
  add     a2, a2, a3
  fcvt.s.w        ft1, a2
  fdiv.s  fa0, ft1, ft0
  mul     a0, a0, a1
  mul     a1, a4, t1
  add     a0, a0, a1
  fcvt.s.w        ft2, a0
  fdiv.s  fa1, ft2, ft0
  ret
