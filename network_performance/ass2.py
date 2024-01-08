import math
def cal2(
    rtt=50,
    bandwidth=100 / 8 * 1024 * 1024 / 1000,
    request_process=50,
    file_size=10 * 1024,
    cwnd=1,
    mss=1460,
):
    return rtt+request_process+  math.ceil(math.log2(math.ceil(file_size/mss)/cwnd+1))*rtt

def cal(
    rtt=50,
    bandwidth=100 / 8 * 1024 * 1024 / 1000,
    request_process=50,
    file_size=10 * 1024,
    cwnd=1,
    mss=1460,
):
    time = rtt *1.5+ request_process
    while file_size > 0:

        packet_num = min(math.ceil(file_size / mss), cwnd)
        print("this round starts from %f, sends %d packets, tranmission time %f, rtt %f "%(time,packet_num,packet_num * mss / bandwidth,rtt))
        time += rtt
        #time += packet_num * mss / bandwidth
        file_size -= packet_num * mss
        cwnd*=2
    return time-rtt/2
print(cal(), cal2())
print(cal(file_size=20*1024),cal2(file_size=20*1024))
print(cal(file_size=50*1024),cal2(file_size=50*1024))
print("=============")
print(cal(cwnd=5), cal2(cwnd=5))
print(cal(cwnd=5,file_size=20*1024),cal2(cwnd=5,file_size=20*1024))
print(cal(cwnd=5,file_size=50*1024),cal2(cwnd=5,file_size=50*1024))
print("=============")


print(cal(rtt=100), cal2(rtt=100))
print(cal(rtt=100,file_size=20*1024),cal2(rtt=100,file_size=20*1024))
print(cal(rtt=100,file_size=50*1024),cal2(rtt=100,file_size=50*1024))