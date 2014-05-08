import sys
from TOSSIM import *
t = Tossim([])
r = t.radio()
f = open("topology.txt", "r")
t.addChannel("Boot", sys.stdout)
t.addChannel("Timer", sys.stdout)
t.addChannel("Radio", sys.stdout)

for line in f:
  s = line.split()
  if s:
    print " ", s[0], " ", s[1], " ", s[2];
    r.add(int(s[0]), int(s[1]), float(s[2]))


#noise = open("meyer-heavy.txt", "r")
#lines = noise.readlines()
#for line in lines:
#    str1 = line.strip()
#    if str1:
#        val = int(str1)
#        for i in range(7):
#            t.getNode(i).addNoiseTraceReading(val)



for i in range(1, 4):
  print "Creating noise model for ",i
  t.getNode(i).createNoiseModel()

t.getNode(1).bootAtTime(100)
t.getNode(2).bootAtTime(800)
t.getNode(3).bootAtTime(1800)

for i in range(10000):
  #print "Action ",i
  t.runNextEvent()
