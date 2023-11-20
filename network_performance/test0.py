def fact(i):
    res=1
    for j in range(1,i+1):
        res*=j
    return res
div=0
for i in range(1,6):
    print(((1.2*20*0.1)**i)/fact(i))
    div+=((1.2*20*0.1)**i)/fact(i)
print((1.2*20*0.1)**5/fact(5)/div)