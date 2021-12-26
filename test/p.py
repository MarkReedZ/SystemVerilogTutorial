

cnt = 0
# We know s[i] == s[j] and i<j 
def isPal(s, i, j):
    #print("isPal ",s,i,j)
    global cnt
    if (j-i) == 1: return True
    i += 1; j -= 1
    while (j>i) and (s[i] == s[j]):
        i += 1; j -= 1; cnt += 1;
    #print(i,j) 
    if i >= j:
        return True
    return False
        

#print(isPal("abba",0,3))
#print(isPal("abca",0,3))
#exit(1)
    
pal = ""
s = "bacbabcdfc"
s = "aaaaabcdfc"
d = {}
for (i,c) in enumerate(s):
    cnt += 1
    if not c in d:
        d[c] = [i]
    else:
        for x in d[c]:
            if isPal( s, x, i ):
                #print("isPal true ",s,x,i)
                
                if (i-x+1) > len(pal):
                    pal = s[x:i+1]
                    print(pal)
                #else:
                    #print( "huh", (i-x), pal, len(pal))
        d[c].append(i)

print(cnt)
