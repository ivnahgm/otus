import os, time
import sys
import signal

def sigtermint_handler(signal, frame):
    print('\nI\'m going home!\n')
    print(os.getpgrp())
    os.killpg(os.getpgrp(), 15)
    sys.exit(0)

def sigchld_handler(signal, frame):
    print('\nWaiting for closing my child!\n')
    os.wait()

signal.signal(signal.SIGTERM, sigtermint_handler)
signal.signal(signal.SIGINT, sigtermint_handler)
signal.signal(signal.SIGCHLD, sigchld_handler)

print('Hello! I am an example')
pid = os.fork()
print('pid of my child is %s' % pid)
if pid == 0:
    print('I am a child. Im going to sleep')
    for i in range(1,40):
      print('mrrrrr')
      a = 2**i
      print(a)
      pid = os.fork()
      if pid == 0:
            print('my name is %s' % a)
            sys.exit(0)
      else:
            print("my child pid is %s" % pid)
      time.sleep(1)
    print('Bye')
    sys.exit(0)

else:
    for i in range(1,200):
      print('HHHrrrrr')

      time.sleep(1)
      print(3**i)
    print('I am the parent')

#pid, status = os.waitpid(pid, 0)
#print "wait returned, pid = %d, status = %d" % (pid, status)

