## MPIAssignment

### 1.Overview

This report is mainly focused on solving the problem mentioned by the assignment, which is to accelerate the Floyd algorithm with three different methods using MPI framework. The efficiency of those methods are quantitatively measured. 

### 2. Tools and theoretical estimation to quantitatively analysis

We use the efficiency to quantitatively evaluate the multi-process accelerated methods. Normally, the efficiency is define as 

$$
efficiency= \frac{time\:on\:1 cpu}{p \times time\:on\:p\:cpus}
$$

Specifically, in this assignment, the efficiency is 

$$
seqT =min_rT_r \\efficiency=\frac{seqT}{np \times min_rmax_wT_{rw}}
$$

where r represent the run, w the worker, np the number of processor and seqT the execution time of the sequential code.

Theoretically, in this assignment the efficiency should be below 100%, because there are always some parts which are not parallel, as well as communication overhead caused by distributive computing.

### 3.Implementation for each method

All these three method are based on the original sequential Floyd algorithm, but:

- In the first method we use `MPI.Send` and  `MPI.Recv` to communicate between different processes, and use `MPI.Barrier ` to coordinate between these processes.
- In the second method we use `MPI.Bcast` to broadcast messages between different processes and coordinate them.
- In the third method we only use `MPI.Send` and  `MPI.Recv` to send messages to communicate between different processes, and in the message, we set the tag to be the row index of the row contained in this message. Each worker maintains a cache and store the newly received row if the row is not the currently wanted row. In this way we no longer need any sort of blocking method.

### 4. Experiment Set-Up

For the size of graph in Floyd algorithm N, we set N=3200.

Before testing these three methods, we shall run test on the sequential method first as the baseline and record the time usage. It will be repeated 5 times, and the minimum value will be used.

We will run tests for different number of processors/workers(NP). Possible values for NP is 2,4,8,16.

For each NP, we run tests on different methods(1 to 3). In the test each method is repeated for 5 times, record the time used on each worker each time, and calculate the efficiency mentioned in Section 2.

### 5. Experiment Result and Analysis

#### 5.1 How does your implementation perform in terms of runtime, and efficiency?

When the number of processor is 4, method 1, 2 and 3 can achieve an efficiency of 95.2%, 95.4%, 96.1%

When the number of processor is 2, method 1, 2 and 3 can achieve an efficiency of 96.2%, 95.9%, 96.6%

When the number of processor is 8, method 1, 2 and 3 can achieve an efficiency of 59.4%, 60.0%, 59.5%
When the number of processor is 16, method 1, 2 and 3 can achieve an efficiency of 30.7%, 30.8%, 31.1%

#### 5.2 What happens to the performance if you scale to more workers?

No matter which method, the efficiency(performance) drops significantly when the number of workers increases. This is because the proportions of the communication costs among all costs on each worker increases.

When the number of workers increases, for each worker, the data amount transferred through communications is still the same, while the amount of calculations decreases. Thats's why the proportions of the communication costs increases and the efficiency drops.

#### 5.3 What effect does the different implementations have on your code?

When the number of workers is fixed, it is always that efficiency of method 1 is smallest, then  efficiency of method 2, and efficiency of method 3 is highest. The reasons are as follow:

1. Method1 uses blocking methods to send messages(Send!), and method1 has to send messages to other works one by one. Besides method1 also use barrier to coordinate different workers every round(for each k). That is why method1 is the least efficient.

2. Method2 uses blocking methods (Bcast!), which also coordinate different workers every round(for each k) . However, method2 calls less blocking methods because it doesn't sends data to other workers one by one.

3. Method3 uses blocking methods to send messages(Send!), but it no longer requires any sort of synchronization and coordination between workers. Instead, tag in MPI message is used to mark the row index of transferred row, and rows supposed to be used later will be cached. By doing so, we can deal without disordered messages correctly without blocking any workers. That is why method3 is the most efficient.

### 6. Appendix 1: Efficiency Results Table (N=3200)

| Functions | Number of Processors = 2 | Number of Processors = 4 | Number of Processors = 8 | Number of Processors = 16 |
| --------- | ------------------------ | ------------------------ | ------------------------ | ------------------------- |
| method 1  | 0.962914                 | 0.952904                 | 0.594619                 | 0.307001                  |
| method 2  | 0.959932                 | 0.954545                 | 0.600062                 | 0.308778                  |
| method 3  | 0.966486                 | 0.961104                 | 0.595842                 | 0.311578                  |

### 7. Appendix 2: Original Test results for np=4

#### 7.1 Baseline

| r   | Tr           |
| --- | ------------ |
| 1   | 32.302392802 |
| 2   | 32.630568008 |
| 3   | 32.261376537 |
| 4   | 32.263299236 |
| 5   | 32.253622576 |

seqT=32.253622576

#### 7.2 Method 1(NP=4)

| r   | w1          | w2          | w3          | w4          | max         |
| --- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1   | 8.559353881 | 8.559353191 | 8.559353182 | 8.559353234 | 8.559353881 |
| 2   | 8.716228715 | 8.716230015 | 8.716227632 | 8.71623005  | 8.71623005  |
| 3   | 8.56136055  | 8.561364865 | 8.561361961 | 8.561364777 | 8.561364865 |
| 4   | 8.461913956 | 8.461925055 | 8.461920958 | 8.461925042 | 8.461925055 |
| 5   | 8.53417861  | 8.534180714 | 8.534177737 | 8.534180736 | 8.534180736 |

$min_rmax_wT_{rw}=8$ efficiency=0.952904

#### 7.3 Method 2(NP=4)

| r   | w1          | w2          | w3          | w4          | max         |
| --- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1   | 8.586442386 | 8.586388021 | 8.58644173  | 8.586360023 | 8.586442386 |
| 2   | 8.568839447 | 8.568825858 | 8.568862961 | 8.568796127 | 8.568862961 |
| 3   | 8.588283984 | 8.58824637  | 8.588309558 | 8.588222052 | 8.588309558 |
| 4   | 8.665619672 | 8.665560708 | 8.665618896 | 8.665538174 | 8.665619672 |
| 5   | 8.447359869 | 8.447381558 | 8.447338707 | 8.447358918 | 8.447381558 |

$min_rmax_wT_{rw}=8$ efficiency=0.954545

#### 7.4 Method 3(NP=4)

| r   | w1          | w2          | w3          | w4          | max         |
| --- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1   | 8.480138924 | 8.480139154 | 8.480127013 | 8.480188394 | 8.480188394 |
| 2   | 8.691141677 | 8.691045032 | 8.691124222 | 8.69104559  | 8.691141677 |
| 3   | 8.517798033 | 8.51781129  | 8.517809677 | 8.517830471 | 8.517830471 |
| 4   | 8.389717679 | 8.38967942  | 8.389729057 | 8.38968674  | 8.389729057 |
| 5   | 8.513858496 | 8.513849661 | 8.513889121 | 8.513849854 | 8.513889121 |

$min_rmax_wT_{rw}=8$ efficiency=0.961104

<!--

#### 6.3 NP=2

##### 6.3.1 Method 1(NP=2)

| r   | w1           | w2           | max          |
| --- | ------------ | ------------ | ------------ |
| 1   | 16.841613063 | 16.841611839 | 16.841613063 |
| 2   | 16.669204783 | 16.669206064 | 16.669206064 |
| 3   | 16.960140381 | 16.960132658 | 16.960140381 |
| 4   | 16.815960406 | 16.815962475 | 16.815962475 |
| 5   | 17.172720322 | 17.172730781 | 17.172730781 |

$min_rmax_wT_{rw}=16$ efficiency=0.962914

##### 6.2.2 Method 2(NP=2)

| r   | w1           | w2           | max          |
| --- | ------------ | ------------ | ------------ |
| 1   | 16.742060801 | 16.741982526 | 16.742060801 |
| 2   | 16.72092302  | 16.720974807 | 16.720974807 |
| 3   | 16.896333505 | 16.896315669 | 16.896333505 |
| 4   | 16.797077481 | 16.797064108 | 16.797077481 |
| 5   | 16.744160531 | 16.74419749  | 16.74419749  |

$min_rmax_wT_{rw}=16$ efficiency=0.959932

##### 6.2.3 Method 3(NP=2)

| r   | w1           | w2           | max          |
| --- | ------------ | ------------ | ------------ |
| 1   | 16.87289041  | 16.872872906 | 16.87289041  |
| 2   | 16.689494359 | 16.689486954 | 16.689494359 |
| 3   | 16.613550292 | 16.613495017 | 16.613550292 |
| 4   | 16.607588437 | 16.607583403 | 16.607588437 |
| 5   | 16.649974349 | 16.649971045 | 16.649974349 |

$min_rmax_wT_{rw}=16$ efficiency=0.966486

#### 6.4 NP=8

##### 6.4.1 Method 1(NP=8)

| r   | w1          | w2          | w3          | w4          | w5          | w6          | w7          | w8          | max         |
| --- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1   | 6.78030149  | 6.780301048 | 6.780309847 | 6.780302743 | 6.780308476 | 6.780302089 | 6.780310235 | 6.780303097 | 6.780310235 |
| 2   | 6.811638948 | 6.811640313 | 6.811637264 | 6.811639415 | 6.811636732 | 6.81164025  | 6.811636189 | 6.811638601 | 6.811640313 |
| 3   | 6.797660544 | 6.797659875 | 6.797666006 | 6.797658763 | 6.79766581  | 6.797659878 | 6.797665202 | 6.797657564 | 6.797666006 |
| 4   | 6.886734353 | 6.886750668 | 6.886746265 | 6.886748397 | 6.886747243 | 6.886749499 | 6.886746442 | 6.886747531 | 6.886750668 |
| 5   | 6.781856205 | 6.781862646 | 6.781867177 | 6.781860428 | 6.781866968 | 6.781862058 | 6.781865672 | 6.781859795 | 6.781867177 |

$min_rmax_wT_{rw}=6$ efficiency=0.594619

##### 6.4.2 Method 2(NP=8)

| r   | w1          | w2          | w3          | w4          | w5          | w6          | w7          | w8          | max         |
| --- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1   | 6.718786567 | 6.718796126 | 6.718750509 | 6.718766719 | 6.718804346 | 6.718811914 | 6.718750245 | 6.718776152 | 6.718811914 |
| 2   | 6.931929403 | 6.931987181 | 6.932043018 | 6.931923579 | 6.931942003 | 6.931913088 | 6.931972183 | 6.93187013  | 6.932043018 |
| 3   | 6.79140699  | 6.791398384 | 6.791453047 | 6.791388849 | 6.791446424 | 6.791393878 | 6.791354082 | 6.791337961 | 6.791453047 |
| 4   | 6.765695918 | 6.765662549 | 6.765661705 | 6.765698302 | 6.765711292 | 6.76564135  | 6.76563557  | 6.765649118 | 6.765711292 |
| 5   | 6.800012741 | 6.799988951 | 6.800002355 | 6.799940491 | 6.800033465 | 6.799952547 | 6.799979516 | 6.799995342 | 6.800033465 |

$min_rmax_wT_{rw}=6$ efficiency=0.600062

##### 6.4.3 Method 3(NP=8)

| r   | w1          | w2          | w3          | w4          | w5          | w6          | w7          | w8          | max         |
| --- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1   | 6.766261103 | 6.766222004 | 6.76633677  | 6.766368958 | 6.766358065 | 6.766400188 | 6.766384306 | 6.766302779 | 6.766400188 |
| 2   | 6.769063581 | 6.768992335 | 6.769006422 | 6.769037032 | 6.76906885  | 6.769074041 | 6.769085543 | 6.768934404 | 6.769085543 |
| 3   | 6.788226315 | 6.78837631  | 6.78832936  | 6.78830954  | 6.788337948 | 6.788445832 | 6.788355105 | 6.788346635 | 6.788445832 |
| 4   | 7.330530608 | 7.330719846 | 7.330586594 | 7.330746228 | 7.330688575 | 7.3307452   | 7.330668289 | 7.330690782 | 7.330746228 |
| 5   | 7.055723925 | 7.055738418 | 7.055745739 | 7.05577694  | 7.055811913 | 7.055835957 | 7.055825853 | 7.055856515 | 7.055856515 |

$min_rmax_wT_{rw}=6$ efficiency=0.595842

#### 6.5 NP=16

##### 6.5.1 Method 1(NP=16)

| r   | w1          | w2          | w3          | w4          | w5          | w6          | w7          | w8          | w9          | w10         | w11         | w12         | w13         | w14         | w15         | w16         | max         |
| --- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1   | 6.786706495 | 6.786708348 | 6.786700944 | 6.786706357 | 6.78670203  | 6.786705529 | 6.786697181 | 6.786702045 | 6.786702725 | 6.786706441 | 6.786699484 | 6.7867043   | 6.786699906 | 6.786703912 | 6.786696732 | 6.786701785 | 6.786708348 |
| 2   | 7.318122294 | 7.31813614  | 7.318128011 | 7.318133209 | 7.318126117 | 7.318131671 | 7.31812336  | 7.318130301 | 7.318127369 | 7.31813393  | 7.318125004 | 7.318132823 | 7.318124831 | 7.318132162 | 7.318122595 | 7.318128818 | 7.31813614  |
| 3   | 6.606690816 | 6.606699867 | 6.606695735 | 6.606699503 | 6.60669363  | 6.606697262 | 6.606691964 | 6.606694384 | 6.606694045 | 6.606698167 | 6.606693807 | 6.606696691 | 6.606691656 | 6.606696849 | 6.606689863 | 6.606694214 | 6.606699867 |
| 4   | 6.566261246 | 6.566264131 | 6.566269169 | 6.56626613  | 6.5662708   | 6.56626666  | 6.566272577 | 6.566269056 | 6.566270993 | 6.566267458 | 6.56627189  | 6.566268778 | 6.566274367 | 6.566269688 | 6.566275885 | 6.56626994  | 6.566275885 |
| 5   | 6.775365272 | 6.775381783 | 6.775374299 | 6.775378257 | 6.775373879 | 6.775378207 | 6.775370292 | 6.775375907 | 6.77537401  | 6.775380242 | 6.775372401 | 6.775378243 | 6.775373574 | 6.775377165 | 6.775369956 | 6.775375329 | 6.775381783 |

$min_rmax_wT_{rw}=6$ efficiency=0.307001

##### 6.5.2 Method 2(NP=16)

| r   | w1          | w2          | w3          | w4          | w5          | w6          | w7          | w8          | w9          | w10         | w11         | w12         | w13         | w14         | w15         | w16         | max         |
| --- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1   | 6.61311288  | 6.613022573 | 6.613088474 | 6.613008639 | 6.613081113 | 6.612986144 | 6.61308611  | 6.613047999 | 6.613069513 | 6.613028651 | 6.613104133 | 6.613060941 | 6.613084752 | 6.613044192 | 6.612958812 | 6.612915533 | 6.61311288  |
| 2   | 6.612559683 | 6.612572198 | 6.612611039 | 6.612553346 | 6.612638198 | 6.612615824 | 6.612584607 | 6.612574764 | 6.61264863  | 6.612561211 | 6.612616366 | 6.612585889 | 6.612644516 | 6.61261362  | 6.612588433 | 6.6125915   | 6.61264863  |
| 3   | 6.669589612 | 6.669482172 | 6.669585976 | 6.669506185 | 6.669569219 | 6.66945677  | 6.669636385 | 6.669538064 | 6.669588213 | 6.669535053 | 6.669612562 | 6.669472167 | 6.66961137  | 6.669497881 | 6.669553302 | 6.669443922 | 6.669636385 |
| 4   | 6.528437788 | 6.528491754 | 6.528449694 | 6.528489252 | 6.528410622 | 6.528468572 | 6.52845335  | 6.528478746 | 6.528426817 | 6.528454296 | 6.528432667 | 6.52844602  | 6.528422134 | 6.528485926 | 6.528422288 | 6.528475574 | 6.528491754 |
| 5   | 6.573218003 | 6.573184696 | 6.573195381 | 6.573202641 | 6.573217668 | 6.573177607 | 6.573198938 | 6.573183731 | 6.573216436 | 6.573203302 | 6.573162023 | 6.573202409 | 6.57318636  | 6.573168337 | 6.573114183 | 6.573048673 | 6.573218003 |

$min_rmax_wT_{rw}=6$ efficiency=0.308778

##### 6.5.3 Method 3(NP=16)

| r   | w1          | w2          | w3          | w4          | w5          | w6          | w7          | w8          | w9          | w10         | w11         | w12         | w13         | w14         | w15         | w16         | max         |
| --- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1   | 6.636312048 | 6.636300926 | 6.636356943 | 6.636498617 | 6.636485054 | 6.636521371 | 6.636509965 | 6.636536227 | 6.636555665 | 6.636591941 | 6.636601164 | 6.636623812 | 6.636624613 | 6.63665821  | 6.63663575  | 6.636668    | 6.636668    |
| 2   | 6.469432236 | 6.469484482 | 6.469551252 | 6.469606801 | 6.469586553 | 6.469619663 | 6.469612526 | 6.46969535  | 6.469669307 | 6.469747888 | 6.469715346 | 6.469756113 | 6.469747661 | 6.469805504 | 6.469742951 | 6.469791828 | 6.469805504 |
| 3   | 6.836342398 | 6.836264124 | 6.836321007 | 6.836323781 | 6.836444308 | 6.836377383 | 6.836511048 | 6.836416935 | 6.836475801 | 6.836491309 | 6.83655011  | 6.836483232 | 6.836590949 | 6.836535431 | 6.836588802 | 6.836493516 | 6.836590949 |
| 4   | 7.003224369 | 7.003300114 | 7.003344941 | 7.003394971 | 7.003414973 | 7.003495344 | 7.003390758 | 7.003549213 | 7.003449983 | 7.00355187  | 7.003445789 | 7.003607018 | 7.003455253 | 7.003626956 | 7.003497835 | 7.003632222 | 7.003632222 |
| 5   | 6.589137151 | 6.589119637 | 6.589198028 | 6.589167286 | 6.589249916 | 6.589300356 | 6.589321028 | 6.589330777 | 6.589342636 | 6.589361219 | 6.589367495 | 6.589395602 | 6.589429241 | 6.589410119 | 6.589432811 | 6.589422273 | 6.589432811 |

$min_rmax_wT_{rw}=6$ efficiency=0.311578
-->