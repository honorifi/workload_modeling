from multiprocessing import Process
import os,sys


def child():
	print("\033[0;32m%s\033[0m"%mpath)
	os.popen('sudo cgexec -g cpuset:small %s >> %s/output/stdout'%(mpath,curdir))


if __name__== '__main__':
	curdir = sys.argv[1]
	os.chdir(curdir)

	mpath = ""
	for i in range(2,len(sys.argv)):
        	mpath += sys.argv[i] + " "
	
	op = raw_input("please enter [Min_cpu_limit] [Max_cpu_limit] [Step]:  (both included; Default: 100 100 1)\n")
	if op == "":
	        start = 100
	        end = 101
	        step = 1
	else:
        	start, end, step = op.split()
        	start = int(start)
        	step = int(step)
        	end = int(end) + 1
	
	os.popen('sudo cgset -r cpuset.cpus=1 -r cpuset.mems=0 small')	
	os.popen('sudo chmod 666 /sys/fs/cgroup/cpu/cpu_test/cpu.cfs_quota_us')
	os.popen('sudo echo \"\" > %s/output/stdout'%curdir)

	for limit in range(start, end, step):
		cpr = Process(target = child)
		fquota = open('/sys/fs/cgroup/cpu/cpu_test/cpu.cfs_quota_us','w')
		fquota.write(str(limit*1000))
		fquota.close()
		cpr.start()
		cpid = cpr.pid
		fo = open('/sys/fs/cgroup/cpu/cpu_test/tasks', 'a')
		fo.write(str(cpid))
		fo.close()
		#os.popen('sudo echo %d >> /sys/fs/cgroup/cpu/cpu_test/tasks'%cpid, 'w')
		cpr.join()
		#os.popen('sudo cgexec -g cpuset:small %s/STREAM/stream_c.exe > /dev/null'%mpath)
		print('test cpu_limit = %d finished...'%limit)
		
