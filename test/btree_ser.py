
z="""
import json
d = { "v":1, "c":[] }

d["c"].append( { "v":2, "c":[] } )
d["c"].append( { "v":3, "c":[] } )
d["c"][1]["c"].append( { "v":4, "c":[] } )
d["c"][1]["c"].append( { "v":5, "c":[] } )

#print(json.dumps(d))
#x = json.loads( json.dumps(d) )
#print(x)


#def ser(self, n, ret):
  #l =     


ret = []

ax1 + by1 + c = ax2 + by2 + c
by1 - by2 = ax2 - ax1
y1-y2 * b = (x2 - x1)*a
-(y2-y1)/x2-x1 = a/b
a = y2-y1 
b = x1-x2
( (y2-y1)x1 + (x1-x2)y1 = -c
(x1-x2)y1 - (y2-y1)x1 = c
x1y1-x2y1 - x1y2 - x1y1 = c
 x2y1 - x1y2 = c
"""

from functools import reduce

def gcd(a, b):
    return gcd(b%a,a) if a != 0 else b

print( reduce(gcd, [10,150,20]))
