

def get( m, lst ):
    i, j = m,m
    while i > 0 and lst[i] == lst[i-1]:
        i -= 1
    while j < (len(lst)-1) and lst[j] == lst[j+1]:
        j += 1
    return [i,j]


lst = [5,7,7,8,8,10,10,10,10]
x = 10

l, h = 0, len(lst)-1
while l < h:
    m = (l+h)//2
    if lst[m] == x:
        print(get(m,lst))

    if x < m:
        h = m-1
    else:
        l = m+1
        
