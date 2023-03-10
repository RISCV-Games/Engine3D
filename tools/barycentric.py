

def barycentric(x1, y1, x2, y2, x3, y3, xp, yp):
    det = (x1-x3)*(y2-y3)-(x2-x3)*(y1-y3)
    u1  = (y2-y3)*(xp-x3) + (x3-x2)*(yp-y3)
    u2  = (y3-y1)*(xp-x3) + (x1-x3)*(yp-y3)
    print(f"DET: {det}")
    print(f"U1*DET: {u1}")
    print(f"U2*DET: {u2}")
    print(f"U1: {u1/det}")
    print(f"U2: {u2/det}")
    print(f"U3: {1-u1/det-u2/det}")


x1 = 0
y1 = 0
x2 = 0
y2 = 319
x3 = 239
y3 = 160
xp = 50
yp = 50


barycentric(x1, y1, x2, y2, x3, y3, xp, yp)
