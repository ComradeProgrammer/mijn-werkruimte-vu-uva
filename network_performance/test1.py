import numpy as np
states=[]
for h in range(0,2):
    for m in range(0,2):
        for l in range(0,3):
            for v in range(0,6):
                if 4*h+3*m+2*l+1*v<=5:
                    states.append([v,l,m,h])
for i in range(0,len(states)):
    print(states[i])
print("==========================")
lambdas=[1.2*20,1.2*0.6*0.7, 1.2*0.6*0.2, 1.2*0.6*0.1]
mus=[10,3,3,3]

edges=[]
for i in range(0,len(states)):
    for j in range(0,len(states)):
        for k in range(0,4):
            new_state=states[i][:]
            new_state[k]+=1
            if new_state==states[j]:
                print(states[i], "->",states[j], lambdas[k])
                edges.append((i,j,lambdas[k]))

            new_state=states[j][:]
            new_state[k]-=1
            if new_state==states[i]:
                print(states[j], "->",states[i], mus[k]*states[j][k])
                edges.append((j,i,mus[k]*states[j][k]))
maxA=[]
for i in range(0,len(states)-1):
    maxA.append([0]*len(states))
maxA.append([1]*len(states))
maxB=[]

for i in range(0,len(states)-1):
    maxB.append([0])
    # find out all incoming edge
    for j in range(0,len(edges)):
        if edges[j][1]==i:
            maxA[i][edges[j][0]]=edges[j][2]
        elif edges[j][0]==i:
            maxA[i][i]+=(-edges[j][2])
maxB.append([1])
maxA=np.array(maxA)
maxB=np.array(maxB)
res=np.dot( np.linalg.inv(maxA),maxB)
for i in range(0,len(states)-1):
    print(states[i],res[i][0])

qres={}
b=[1,2,3,4]
for i in range(0,len(states)):
    occupy=sum([states[i][j]*b[j] for j in range(0,4)])
    if occupy not in qres:
        qres[occupy]=0
    qres[occupy]+=res[i][0]
print(qres)
res=[0]*4
for i in range(0,4):
    for j in range(5-b[i]+1,6):
        res[i]+=qres[i]
print(res)

'''
[[0.07992871]
 [0.19182891]
 [0.23019469]
 [0.18415575]
 [0.11049345]
 [0.05303686]
 [0.01342802]
 [0.03222726]
 [0.03867271]
 [0.03093817]
 [0.00112795]
 [0.00270709]
 [0.00383658]
 [0.00920779]
 [0.01104935]
 [0.00064455]
 [0.00191829]
 [0.00460389]]
'''