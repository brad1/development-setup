import os
import resource
import sys
import time
from subprocess import Popen, PIPE

cmd = 'grep -r "main" .' 
stime = time.time()
p = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE, close_fds=True)
etime = time.time()
print(p.stdout.read())
print(p.stderr.read())


real_time = etime - stime

print("real\t" + str(real_time))
