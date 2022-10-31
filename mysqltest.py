from multiprocessing import Process
import os,sys,pwd,subprocess,time


def child(start, end, step):
	#print("\033[0;32m%s\033[0m"%mpath)
	ex = subprocess.Popen('exec ./sysmemory.sh %d %d %d %s'%(start, end, step, curdir), shell=True)
	status = ex.wait()
	print("workload:%s exited(code: %d)"%(mpath,status))


class Back_Mission:
	def __init__(self):
		os.popen('echo \"\" > %s/output/stdout'%curdir)
		ex = None
	def start(self):
		self.ex = subprocess.Popen('cgexec -g cpuset:back_mission /usr/local/bin/sysbench /home/kongxc/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --oltp-test-mode=complex --oltp-tables-count=10 --oltp-table-size=1000000 --threads=8 --oltp-read-only=off --time=1200 --report-interval=10 run >> %s/output/stdout'%curdir, shell=True)
	def terminate(self):
		self.ex.kill()
	def join(self):
		status = self.ex.wait()
                print("sysbench exited(code: %d)"%status)



if __name__== '__main__':
	#print(pwd.getpwuid(os.getuid())[0])	

	curdir = sys.argv[1]
	os.chdir(curdir)

	mpath = ""
	for i in range(2,len(sys.argv)):
        	mpath += sys.argv[i] + " "
	
	op = raw_input("please enter [Min_cpu_limit] [Max_cpu_limit] [Step]:  (both included; Default: 100 100 1)\n")
	op = op.split()
	while len(op) < 4:
		op.append("")
	if op[0] == "":
	        start = 100
	else:
		start = int(op[0])
	if op[1] == "":
                end = 100
        else:
                end = int(op[1]) + 1
	if op[2] == "":
                step = 1
        else:
                step = int(op[2])

	#back_mission = Back_Mission()
	#back_mission.start()	
	
	print('\033[0;31mPlease do not terminate shell !!!\nif you have to, remember to kill stream_c.exe process manually, cause it wont exit itself\033[0m')	
	is_wait = raw_input("wait 30s to make mysql stable? [y/n] (default: n)")
	if is_wait == "y":
		time.sleep(30)

	cpr = Process(target = child, args = (start,end,step))
	cpr.start()
	cpr.join()
	
	#back_mission.terminate()
	#back_mission.join()	
