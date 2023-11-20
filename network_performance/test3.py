'''
2+4+8+12+10=36

1/18 1/9 2/9 1/3 5/18

x1+x2+x3=50
x3+x4+x5=50

lambda=[2 4 8 12 10]
beta=[2 2 2 2 2]

'''
cache={}
def run(N):
    def fact(i):
        res=1
        for j in range(1,i+1):
            res*=j
        return res 

    def erlang(n,lmbda,beta=2):
        if (n,lmbda) in cache:
            return cache[(n,lmbda)]
        div=1
        for i in range(1,n+1):
            div+=(lmbda*beta)**i/fact(i)
        res=(lmbda*beta)**n/fact(n)/div
        cache[(n,lmbda)]=res
        return res
    res=1
    resx=[]
    prob=[1/18 ,1/9, 2/9, 1/3, 5/18]
    lambdas=[2 ,4 ,8 ,12, 10]
    for x3 in range(0,N):
        for x1 in range(0,N-x3):
            for x4 in range(0,N-x3):
                x2=N-x1-x3
                x5=N-x3-x4
                x=[x1,x2,x3,x4,x5]
                p=0
                for i in  range(0,5):
                    p+=(prob[i]*erlang(x[i],lambdas[i]))
                if p<res:
                    res=p
                    resx=x
    return (res,resx)
    '''0.2226153912965448 [15, 22, 13, 20, 17]'''

run(50)

for i in range(50,200):
    res=run(i)
    print(i,res)
    if res[0]<0.01:
        break
