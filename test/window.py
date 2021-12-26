
s = "AB0CABCABC"
t = "ABC"

d={}
n = 0
dp = []
for c in s:
    dp.append(len(s)*[0])
print(dp)
for c in t:
    d[c] = 1<<n
    n += 1
    
ret = len(s)*"z"
mask = 0
for k in d.keys():
    mask |= d[k]
print(s)
q = [0]
bits = 0
while len(q):
    bits = 0
    i = q[0]
    start = i
    while i < len(s):
        c = s[i]
        if c in d:
            if i > q[-1]: q.append(i)
            bits |= d[c]
            if bits == mask:
                if i - start < len(ret):
                    ret = s[start:i+1]
                    if len(ret) == len(t): 
                        q = [0] # Bail
                break
        i += 1
    del q[0]

                    
print(ret)                    

        
        
