def fact(i):
    res=1
    for j in range(1,i+1):
        res*=j
    return res
states=[]
for h in range(0,2):
    for m in range(0,2):
        for l in range(0,3):
            for v in range(0,6):
                if 4*h+3*m+2*l+1*v<=5:
                    states.append([v,l,m,h])
lambdas=[1.2*20,1.2*0.6*0.7, 1.2*0.6*0.2, 1.2*0.6*0.1]
ds=[1/10,1/3,1/3,1/3]
rou=[lambdas[i]*ds[i] for i in range(0,4)]

products=[]
for i in range(0,len(states)):
    tmp=1
    for j in range(0,4):
        n=states[i][j]
        tmp*=(rou[j]**n)/fact(n)
    products.append(tmp)
g=sum(products)

for i in range(0,len(states)):
    products[i]= products[i]/g
    print(states[i],products[i])
'''
[0.07992871126270992, 0.19182890703050381, 0.23019468843660462, 0.18415575074928373, 0.11049345044957025, 0.05303685621579373, 0.013428023492135264, 0.03222725638112464, 0.03867270765734957, 0.030938166125879664, 0.0011279539733393621, 0.0027070895360144696, 0.0038365781406100754, 0.009207787537464183, 0.011049345044957021, 0.0006445451276224926, 0.0019182890703050377, 0.004603893768732091]

'''