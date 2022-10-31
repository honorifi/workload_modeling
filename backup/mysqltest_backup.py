from multiprocessing import Process
import os,sys,pwd


def child():
	#print("\033[0;32m%s\033[0m"%mpath)
	os.popen('sudo cgexec -g cpuset:small %s > /dev/null'%mpath)


def sysbench_mysql_run():
	os.popen('/usr/local/bin/sysbench /home/kongxc/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --oltp-test-mode=complex --oltp-tables-count=10 --oltp-table-size=1000000 --threads=10 --time=120 --report-interval=10 run >> %s/output/stdout'%curdir)
	

if __name__== '__main__':
	#print(pwd.getpwuid(os.getuid())[0])	

	curdir = sys.argv[1]
	os.chdir(curdir)

	mpath = ""
	for i in range(2,len(sys.argv)):
        	mpath += sys.argv[i] + " "
	
	op = raw_input("please enter [Min_cpu_limit] [Max_cpu_limit] [Step] [Repeat]:  (both included; Default: 100 100 1 1)\n")
	if op == "":
	        start = 100
	        end = 101
	        step = 1
		repeat = 1
	else:
        	start, end, step, repeat = op.split()
        	start = int(start)
        	step = int(step)
        	end = int(end) + 1
		repeat = int(repeat)
	
	os.popen('sudo cgset -r cpuset.cpus=1 -r cpuset.mems=0 small')	
	os.popen('sudo chmod 666 /sys/fs/cgroup/cpu/cpu_test/cpu.cfs_quota_us')
	os.popen('sudo echo \"\" > %s/output/stdout'%curdir)
		
	back_mission = Process(target = sysbench_mysql_run)
	back_mission.start()	

	for limit in range(start, end, step):
		fquota = open('/sys/fs/cgroup/cpu/cpu_test/cpu.cfs_quota_us','w')
		fquota.write(str(limit*1000))
		fquota.close()
		print("\033[0;32m%s\033[0m"%mpath)
		for tmp_cnt in range(repeat*limit//start):
			cpr = Process(target = child)
			cpr.start()
			cpid = cpr.pid
			fo = open('/sys/fs/cgroup/cpu/cpu_test/tasks', 'a')
			fo.write(str(cpid))
			fo.close()
		#os.popen('sudo echo %d >> /sys/fs/cgroup/cpu/cpu_test/tasks'%cpid, 'w')
			cpr.join()
		#os.popen('sudo cgexec -g cpuset:small %s/STREAM/stream_c.exe > /dev/null'%mpath)
		print('test cpu_limit = %d finished...'%limit)
	back_mission.terminate()
	back_mission.join()	
