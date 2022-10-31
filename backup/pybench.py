from multiprocessing import Process
import os,sys

mpath = sys.argv[1]

def child(cnt):
	os.popen('sudo cgexec -g cpuset:small %s/STREAM/stream_c.exe > /dev/null'%mpath)
	print('test run %d times'%cnt)

os.popen('sudo cgset -r cpuset.cpus=1 -r cpuset.mems=0 small')

cnt = 1

while True:
	cpr = Process(target = child, args=(cnt,))
	cpr.start()
	cpid = cpr.pid
	fo = open('/sys/fs/cgroup/cpu/cpu_test/tasks', 'a')
	fo.write(str(cpid))
	fo.close()
	#os.popen('sudo echo %d >> /sys/fs/cgroup/cpu/cpu_test/tasks'%cpid, 'w')
	cpr.join()
	#os.popen('sudo cgexec -g cpuset:small %s/STREAM/stream_c.exe > /dev/null'%mpath)
	#print('test run %d times'%cnt)
	cnt+=1
