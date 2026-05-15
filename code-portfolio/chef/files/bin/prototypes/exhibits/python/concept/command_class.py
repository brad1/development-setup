import time
from subprocess import Popen, PIPE

class ShellCommand:
  def __init__(self, command_text):
    self.ct = command_text

  def execute(self):
    self.__starttime()
    p = Popen(self.ct, shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE, close_fds=True)
    self.__endtime()
    out = p.stdout.read()
    err = p.stderr.read()
    print(self.duration)
    print(out)
    print(err)

  def __starttime(self):
    self.stime = time.time()
    
  def __endtime(self):
    self.duration = time.time() - self.stime
    
