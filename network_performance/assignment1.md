# Assignment 1

## I. Planning of cellular telephone networks with video-conferencing services

### I-1 Model for the problem

- The size of the hex is $s$ square kilometer

- Calls come in with rate $r=20$ per hour per square kilometer following the Poisson distribution.

- Call duration is exponentially distributed with average $\beta = 0.1$ hours

- One base station is in charge of one hex, and the capacity of its channels is $N = 5$

- size of a cell is $s = 1.2 km^2$
  
  ### I-2 Formula of blocking probability
  
  $$
  \lambda=rs \\
erlang(N,\lambda,\beta)=\frac{\frac{(\lambda\beta)^N}{N!}}{\sum_{i=0}^{N} \frac{(\lambda\beta)^i}{i!}}
  $$

The result is 0.0624

### I-3 Insensitivity on distribution of call duration

Answer: the formula still works even the distribution of call duration is not exponential. 

That is because of the PASTA (Poisson Arrivals See Time Averages) attributes of Poisson distribution. As long as the call occurs following the Poisson distribution, we shall always see the average time of call duration regardless of the distribution of call duration.

### I-4 Insensitivity on inter-arrival time distribution cannot work

Answer: No, the formula will not work if inter-arrival time distribution is no longer Poisson. Because under such circumstance, the PASTA attribute no longer holds, and the state transition equation in the Markov chain no longer holds.

A counter-example: Suppose we changed the inter-arrival time distribution as follow:
*There are always N+1 calls come in together every 10 minutes*,

Then the blocking probability would be actually 1, which would show that the formula no longer works.

### I-5 Arrival rate triples, average call duration to 1/3

Intuition: Nothing happens.

Because the average of total call duration required every minutes does not change, while inter-arrival time distribution is still Poisson.

### I-6 The markov chain, state space, and transition rates

The state space S: 

```
S={(0, 0, 0, 0),(1, 0, 0, 0),(2, 0, 0, 0),(3, 0, 0, 0),(4, 0, 0, 0),(5, 0, 0, 0),(0, 1, 0, 0),(1, 1, 0, 0),(2, 1, 0, 0),(3, 1, 0, 0),(0, 2, 0, 0),(1, 2, 0, 0),(0, 0, 1, 0),(1, 0, 1, 0),(2, 0, 1, 0),(0, 1, 1, 0),(0, 0, 0, 1),(1, 0, 0, 1)}
```

The transition rates between the states are

```
[0, 0, 0, 0] -> [1, 0, 0, 0] 24.0
[1, 0, 0, 0] -> [0, 0, 0, 0] 10
[0, 0, 0, 0] -> [0, 1, 0, 0] 0.504
[0, 1, 0, 0] -> [0, 0, 0, 0] 3
[0, 0, 0, 0] -> [0, 0, 1, 0] 0.144
[0, 0, 1, 0] -> [0, 0, 0, 0] 3
[0, 0, 0, 0] -> [0, 0, 0, 1] 0.072
[0, 0, 0, 1] -> [0, 0, 0, 0] 3
[1, 0, 0, 0] -> [2, 0, 0, 0] 24.0
[2, 0, 0, 0] -> [1, 0, 0, 0] 20
[1, 0, 0, 0] -> [1, 1, 0, 0] 0.504
[1, 1, 0, 0] -> [1, 0, 0, 0] 3
[1, 0, 0, 0] -> [1, 0, 1, 0] 0.144
[1, 0, 1, 0] -> [1, 0, 0, 0] 3
[1, 0, 0, 0] -> [1, 0, 0, 1] 0.072
[1, 0, 0, 1] -> [1, 0, 0, 0] 3
[2, 0, 0, 0] -> [3, 0, 0, 0] 24.0
[3, 0, 0, 0] -> [2, 0, 0, 0] 30
[2, 0, 0, 0] -> [2, 1, 0, 0] 0.504
[2, 1, 0, 0] -> [2, 0, 0, 0] 3
[2, 0, 0, 0] -> [2, 0, 1, 0] 0.144
[2, 0, 1, 0] -> [2, 0, 0, 0] 3
[3, 0, 0, 0] -> [4, 0, 0, 0] 24.0
[4, 0, 0, 0] -> [3, 0, 0, 0] 40
[3, 0, 0, 0] -> [3, 1, 0, 0] 0.504
[3, 1, 0, 0] -> [3, 0, 0, 0] 3
[4, 0, 0, 0] -> [5, 0, 0, 0] 24.0
[5, 0, 0, 0] -> [4, 0, 0, 0] 50
[0, 1, 0, 0] -> [1, 1, 0, 0] 24.0
[1, 1, 0, 0] -> [0, 1, 0, 0] 10
[0, 1, 0, 0] -> [0, 2, 0, 0] 0.504
[0, 2, 0, 0] -> [0, 1, 0, 0] 6
[0, 1, 0, 0] -> [0, 1, 1, 0] 0.144
[0, 1, 1, 0] -> [0, 1, 0, 0] 3
[1, 1, 0, 0] -> [2, 1, 0, 0] 24.0
[2, 1, 0, 0] -> [1, 1, 0, 0] 20
[1, 1, 0, 0] -> [1, 2, 0, 0] 0.504
[1, 2, 0, 0] -> [1, 1, 0, 0] 6
[2, 1, 0, 0] -> [3, 1, 0, 0] 24.0
[3, 1, 0, 0] -> [2, 1, 0, 0] 30
[0, 2, 0, 0] -> [1, 2, 0, 0] 24.0
[1, 2, 0, 0] -> [0, 2, 0, 0] 10
[0, 0, 1, 0] -> [1, 0, 1, 0] 24.0
[1, 0, 1, 0] -> [0, 0, 1, 0] 10
[0, 0, 1, 0] -> [0, 1, 1, 0] 0.504
[0, 1, 1, 0] -> [0, 0, 1, 0] 3
[1, 0, 1, 0] -> [2, 0, 1, 0] 24.0
[2, 0, 1, 0] -> [1, 0, 1, 0] 20
[0, 0, 0, 1] -> [1, 0, 0, 1] 24.0
[1, 0, 0, 1] -> [0, 0, 0, 1] 10
```

### I-7

The code in Appendix 1 was used to calculate the result by generating the balancing equations and solve it. The possibility for each state is as follow 

```
[0, 0, 0, 0] 0.07992871126270996
[1, 0, 0, 0] 0.1918289070305039
[2, 0, 0, 0] 0.23019468843660473
[3, 0, 0, 0] 0.18415575074928378
[4, 0, 0, 0] 0.11049345044957026
[5, 0, 0, 0] 0.05303685621579372
[0, 1, 0, 0] 0.01342802349213527
[1, 1, 0, 0] 0.03222725638112465
[2, 1, 0, 0] 0.03867270765734958
[3, 1, 0, 0] 0.03093816612587966
[0, 2, 0, 0] 0.0011279539733393623
[1, 2, 0, 0] 0.002707089536014469
[0, 0, 1, 0] 0.003836578140610077
[1, 0, 1, 0] 0.009207787537464186
[2, 0, 1, 0] 0.011049345044957023
[0, 1, 1, 0] 0.000644545127622493
[0, 0, 0, 1] 0.0019182890703049553
```

### I-8

The code in Appendix 2 was used to calculate the result by product-form theorem
The result is as follow (which is equal with the answer in I-7 within an acceptable small floating point error)

```
[0, 0, 0, 0] 0.07992871126270992
[1, 0, 0, 0] 0.19182890703050381
[2, 0, 0, 0] 0.23019468843660462
[3, 0, 0, 0] 0.18415575074928373
[4, 0, 0, 0] 0.11049345044957025
[5, 0, 0, 0] 0.05303685621579373
[0, 1, 0, 0] 0.013428023492135264
[1, 1, 0, 0] 0.03222725638112464
[2, 1, 0, 0] 0.03867270765734957
[3, 1, 0, 0] 0.030938166125879664
[0, 2, 0, 0] 0.0011279539733393621
[1, 2, 0, 0] 0.0027070895360144696
[0, 0, 1, 0] 0.0038365781406100754
[1, 0, 1, 0] 0.009207787537464183
[2, 0, 1, 0] 0.011049345044957021
[1, 0, 0, 1] 0.004603893768732091
[0, 1, 1, 0] 0.0006445451276224926
[0, 0, 0, 1] 0.0019182890703050377
```

### I-9

Append the code in Appendix 3 to the code snippet in Appendix 1, then the result is that:
```[0.07992871126270992, 0.38365781406100763, 0.7308681357862197, 0.8808783410840739]```
Which means, the block probability for these four call classes are:

- voice: 0.07992871126270996
- low quality video: 0.3836578140610078
- medium quality video: 0.73086813578622
- high quality video:  0.880878341084074

### I-10 Kaufman-Roberts recursion

We define q(c) as probability that in total exactly c channels are occupied, and first we use Kaufman-Roberts recursion to calculate it.

First we define some parameters according to the information in the question

$$
\lambda(1)=1.2*20 \qquad
\lambda(2)=1.2*0.6*0.7 \qquad
\lambda(3)=1.2*0.6*0.2 \qquad
\lambda(4)=1.2*0.6*0.1 \\
d(1)=\frac{1}{10} \qquad d(2)=d(3)=d(4)=\frac{1}{3} \\
b(1)=1 \qquad b(2)=2 \qquad b(3)=3 \qquad b(4)=4 \\
\rho(1)=\lambda(1)d(1) \qquad
\rho(2)=\lambda(2)d(2) \qquad
\rho(3)=\lambda(3)d(3) \qquad
\rho(4)=\lambda(4)d(4) \\
$$

After that, we calculate g(c) by the following steps:

- g(0)=1
- g(c)=$\frac{1}{c} \sum_{j=1}^{4} b(j)\rho(j)g(c-b(j))$
- normalize it so that sum of g(c) is 1

Then the g(c) is the q(c) we want. With q(c) we calculate the blocking probability for each class by 
$B(j)= \sum_{c=5-b(j)+1}^{5} q(c)$

### I-11  Program for the Kaufman-Roberts recursion

In the following program we first calculate q(c), which is probability that in total exactly c channels are occupied. Based on the q(c) we calculate the blocking probability for each call class. The result is:

- voice: 0.07992871126270992
- low quality video: 0.38365781406100763
- medium quality video: 0.7308681357862197
- high quality video:  0.8808783410840739

The result is equal to the answer given in I-9 within an acceptable floating point error.

```python
g=[1.0,0,0,0,0,0]
lambdas=[1.2*20,1.2*0.6*0.7, 1.2*0.6*0.2, 1.2*0.6*0.1]
ds=[1/10,1/3,1/3,1/3]
b=[1,2,3,4]
rou=[lambdas[i]*ds[i] for i in range(0,4)]
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
```

### I-12

Nothing will change. Just like the answer we gave in the I-3, our calculation process for the probability does not rely on the distribution of the call duraion, because PASTA attribute assures that we always see the average of the call duration。

## II Optimal distribution of channels over neighboring cells in mobile voice networks

### II-13

We define the Erlang-B formula is $erlang(n,\lambda, \beta)$.

In this question, the termination rate $\beta$ for all blocks are 2, while as for the arriving rate, for block 1-5, $\lambda_1=2, \lambda_2=4,\lambda_3=8, \lambda_3=12, \lambda_3=10$.

Suppose the number of channels in block 1,2,3,4,5 is $x_1 x_2 x_3 x_4 x_5$
Then according to the "no interferences" requirements, we can have the following constraints:

$$
x_1 + x_2 +x_3 \leq 50 \\
x_3 + x_4 + x_5 \leq 50\\
x_1, x_2, x_3 ,x_4 ,x_5 \in N_+ \\
$$

For one single call, the probability that it happens in block 1-5 is $p_1=1/18, p_2=1/9, p_3=2/9, p_4=1/3, p_5=5/18$.

Then the blocking probability of a call, which is also the target we want to minimize is 

$$
p=\sum_{j=1}^{5} p_j\times erlang(x_j,\lambda_j,\beta)
$$

Besides, it is easy to find that in the no interferences constraints, we can substitute the less equal sign into equal sign, because we are trying to minimize the blocking probability, and the more channels are, the less the blocking probability will be.

Therefore the final quantitive description is as follow:

$$
x_1 + x_2 +x_3 = 50 \\
x_3 + x_4 + x_5 = 50\\
x_1, x_2, x_3 ,x_4 ,x_5  \in N_+ \\

minimize \quad p=\sum_{j=1}^{5} p_j\times erlang(x_j,\lambda_j,\beta)
$$

We use the python script in  Appendix4 to solve this problem, and the result is 

$p=0.2226153912965448, \\x_1=15, x_2=22, x_3=13, x_4=20, x_5=17$

### II-14

This time the problem change to

$$
x_1, x_2, x_3 ,x_4 ,x_5  \in N_+ \\
p=\sum_{j=1}^{5} p_j\times erlang(x_j,\lambda_j,\beta) < 0.1 \\

minimize  \quad x_1+x_2+x_3+x_4+x_5
$$

Append code in Appendix 5 in Appendix 4, and we can solve the problem, the result is:

The optimal allocation is 
$ x_1=27, x_2=37, x_3=24, x_4=34, x_5=30$. 
The blocking probability is p=0.00929562973797542

In total, we need max(x1+x2+x3，x3+x4+x5)=88 channels.

## Appendix

### Appendix 1

```python
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
```

### Appendix 2

```python
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
print(products)
'''
[0.07992871126270992, 0.19182890703050381, 0.23019468843660462, 0.18415575074928373, 0.11049345044957025, 0.05303685621579373, 0.013428023492135264, 0.03222725638112464, 0.03867270765734957, 0.030938166125879664, 0.0011279539733393621, 0.0027070895360144696, 0.0038365781406100754, 0.009207787537464183, 0.011049345044957021, 0.0006445451276224926, 0.0019182890703050377, 0.004603893768732091]

'''
```

### Appendix 3

```python
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
```

### Appendix 4

```python
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
```