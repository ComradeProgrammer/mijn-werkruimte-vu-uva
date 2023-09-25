import random
from typing import List
import matplotlib.pyplot as plt

TEST_TIME=500000


def get_tri_distribution_pdf(a: int,b:int,c:int):
    def pdf(x:int):
        if x<a or x>b:
            return 0
        elif x>=a and x<c:
            return 2*(x-a)/((b-a)*(c-a))
        elif x==c:
            return 2/(b-a)
        elif x>c and x<=b:
            return 2*(b-x)/((b-a)*(b-c))
    return pdf

def generate_tri_distribution_random_number(a:int,b:int,c:int):
    pdf=get_tri_distribution_pdf(a,b,c)
    while True:
        rand_x=random.random()*(b-a)+a
        rand_y=random.random()*(2/(b-a))
        if rand_y<=pdf(rand_x):
            return rand_x
        

def generate_pdf_picture(arr:List[int]):
    y=[]
    x=[]
    BUCKETS=1000
    arr.sort()
    min_value=arr[0]
    max_value=arr[-1]
    div=(max_value-min_value)/BUCKETS
    for i in range (0,BUCKETS+1):
        y.append(0)
        x.append(min_value+i*div)
    
    for i in arr:
        index=int((i-min_value)/div)
        y[index]+=1

    new_x=[]
    new_y=[]
    for i in range (0,BUCKETS+1):
        if y[i]!=0:
            new_x.append(x[i])
            new_y.append(y[i]/len(arr))
            
    plt.plot(new_x,new_y)
    plt.show()
def generate_cdf_picture(arr:List[int]):
    y=[]
    x=[]
    BUCKETS=1000
    arr.sort()
    min_value=arr[0]
    max_value=arr[-1]
    div=(max_value-min_value)/BUCKETS
    for i in range (0,BUCKETS+1):
        y.append(0)
        x.append(min_value+i*div)
    
    for i in arr:
        index=int((i-min_value)/div)
        y[index]+=1

    new_x=[]
    new_y=[]
    for i in range (0,BUCKETS+1):
        if y[i]!=0:
            new_x.append(x[i])
            new_y.append(y[i])

    for i in range (1,len(new_y)):
        new_y[i]+=new_y[i-1]
    for i in range (0,len(new_y)):
        new_y[i]=new_y[i]/len(arr)
    plt.axis([min_value,max_value,0,1]) 
    plt.plot(new_x,new_y)
    plt.xlabel('cost containing risk (million USD)')
    plt.ylabel('possibility')
    plt.title('Cumulative distribution function of cost containing risk')
    plt.show()


if __name__ =="__main__":
    tmp=[]
    for i in range(0,TEST_TIME):
        risk1=generate_tri_distribution_random_number(0,222000,0)
        risk2=generate_tri_distribution_random_number(5428000,12972000,8510000)
        risk3=generate_tri_distribution_random_number(12470849,13825852.7,13000000)
        tmp.append((risk1+risk2+risk3)/1000000)
    #generate_pdf_picture(tmp)
    generate_cdf_picture(tmp)