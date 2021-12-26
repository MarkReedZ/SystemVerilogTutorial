
lst = []
def perm( s, left, right, ret=[] ):
    global lst
    if left:          perm( s+'(', left-1, right )
    if right > left:  perm( s+')', left, right-1 )
    print( left,right,s )
    if not right: lst.append(s)

n = 3
perm('',n,n)
print( lst )

