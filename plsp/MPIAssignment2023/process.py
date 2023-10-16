import os
import json
baseline=32.253622576
for i in range(1,4):
    print('''| r | w1 |w2 |w3 |w4 |max |
| -- | -- | --| -- | -- | --|''')

    file_names=os.listdir(os.getcwd())
    min_value=10000
    row=1
    for file_name in file_names:
        if file_name.endswith("_"+str(i)+".json"):
            print("|"+str(row)+"|",end="")
            with open(file_name,"r") as f:
                data=json.loads(f.read())
                max_time=0
                for t in data["time"]:
                    print(t,end="|")
                    max_time=max(max_time,t)
                print(str(max_time)+"|")
                min_value=min(min_value,max_time)
                row+=1
    print("$min_rmax_wT_{rw}=%d$ efficiency=%f"%(min_value,baseline/(16*min_value)))
    print()
