

class Node:
    def __init__(self, val):
        self.n = None
        self.v  = val

r = Node(4)
r.n = Node(2)
r.n.n = Node(1)
r.n.n.n = Node(3)

d = {}
n = r
while(n):
    d[n.v] = d.get(n.v,[]) + [n]
    print(n.v)
    n = n.n

l = sorted(d.keys())

print(l) 

r = None
n = None
for k in l:
    for nn in d[k]:
        if r == None:
            r = nn
            n = r
        else:
            n.n = nn
            n = n.n  

n.n = None

n = r
while(n):
    print(n.v)
    n = n.n
