g=[1.0,0,0,0,0,0]
lambdas=[1.2*20,1.2*0.6*0.7, 1.2*0.6*0.2, 1.2*0.6*0.1]
ds=[1/10,1/3,1/3,1/3]
b=[1,2,3,4]
rou=[lambdas[i]*ds[i] for i in range(0,4)]
print(rou)
for i in range(1,6):
    tmp=0
    for j in range(0,4):
        if i-b[j]>=0:
            tmp+=b[j]*rou[j]*g[i-b[j]]
    g[i]=tmp/i
s=sum(g)
for i in range(0,6):
    g[i]=g[i]/s
print(g)


res=[0]*4
for i in range(0,4):
    for j in range(5-b[i]+1,6):
        res[i]+=g[i]
print(res)