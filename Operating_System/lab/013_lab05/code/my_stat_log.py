import sys
import copy

P_N = 0
P_J = 1
P_R = 2
P_W = 3
P_E = 4

HZ = 100 

class process:
    def __init__(self, pid, time) -> None:
        self.pid = pid
        self.state = [(P_N, time)]
        self.trunaround_time = 0
        self.waiting_time = 0
        self.cpu_time = 0
        self.io_time = 0

    def change_state(self, state, time):
        self.state.append((state, time))

process_pool = []

argv = sys.argv
argc = len(argv)

f = open(argv[1], 'r')
pid_list = [int(argv[i]) for i in range(2, argc)]

for lineno, line in enumerate(f):
    fileds = line.split('\t')
    pid = int(fileds[0])
    s = fileds[1]
    time = int(fileds[2])

    if pid in pid_list:
        if s == 'N':
            process_pool.append(process(pid, time))
        elif s == 'J':
            for p in process_pool:
                if p.pid == pid and p.state[-1][0] != P_J and p.state[-1][0] != P_E:
                    p.change_state(P_J, time)
                else: 
                    continue
        elif s == 'R':
            for p in process_pool:
                if p.pid == pid and p.state[-1][0] != P_E:
                    p.change_state(P_R, time)
        elif s == 'W':
            for p in process_pool:
                if p.pid == pid and p.state[-1][0] != P_W and p.state[-1][0] != P_E:
                    p.change_state(P_W, time)
                else:
                    continue
        elif s == 'E':
            for p in process_pool:
                if p.pid == pid:
                    p.change_state(P_E, time)

for p in process_pool:
    if p.state[-1][0] != P_E:
        exit(1)
    for i in range(0, len(p.state) - 1):
        if p.state[i][0] == P_J or p.state[i][0] == P_N:
            p.waiting_time += p.state[i + 1][1] - p.state[i][1]
        elif p.state[i][0] == P_W:
            p.io_time += p.state[i + 1][1] - p.state[i][1]
        elif p.state[i][0] == P_R:
            p.cpu_time += p.state[i + 1][1] - p.state[i][1]
    p.trunaround_time = p.state[-1][1] - p.state[0][1]

print("PID\t\tTurnaround\tWaiting\t\tCPU Time\tIO Time")
for p in process_pool:
    print("%d\t\t%d\t\t%d\t\t%d\t\t%d" % \
          (p.pid, p.trunaround_time, p.waiting_time, p.cpu_time, p.io_time))
print("Average:\t%.1f\t\t%.1f" % \
      (sum([p.trunaround_time for p in process_pool]) / len(process_pool), \
       sum([p.waiting_time for p in process_pool]) / len(process_pool)))
print("Throughout:\t%.5f/s" % \
      (len(process_pool) / max([p.state[-1][1] - p.state[0][1] for p in process_pool]) * HZ))

# print all process state
# for p in process_pool:
#     print("PID: %d" % p.pid)
#     for s in p.state:
#         if s[0] == P_N:
#             print("N\t%d" % s[1])
#         elif s[0] == P_J:
#             print("J\t%d" % s[1])
#         elif s[0] == P_R:
#             print("R\t%d" % s[1])
#         elif s[0] == P_W:
#             print("W\t%d" % s[1])
#         elif s[0] == P_E:
#             print("E\t%d" % s[1])
#     print("")
