
def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a,b = b, a+b
    return a


print(fib(2))
print(fib(3))
print(fib(4))
print(fib(5))

