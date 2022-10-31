#read -p $'please enter workload running instruction: [default: stream]\n' script_dir
echo 'this is sysbench-oltp test for cpu usage limit...'
#if [ -z "$script_dir" ];
#then
#	script_dir="./STREAM/stream_c.exe"
#fi
#echo $'\33[31minstruction: \33[0m' $script_dir $'\t\t\33[32mnum_proc: \33[0m' $num_proc

curdir=$(cd $(dirname $0); pwd)


echo "" > $curdir/output/stdout
#sudo cgcreate -g cpuset:back_mission
#sudo cgset -r cpuset.cpus=1-10 -r cpuset.mems=1 back_mission
/usr/local/bin/sysbench /home/kongxc/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --oltp-test-mode=complex --rand-init=on --oltp-tables-count=10 --oltp-table-size=1000000 --threads=16 --time=1200 --report-interval=10 run >> $curdir/output/stdout &

#echo "" > $curdir/output/stdout
#sysbench /home/kongxc/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --oltp-test-mode=complex --oltp-tables-count=10 --oltp-table-size=1000000 --threads=10 --time=120 --report-interval=10 run >> $curdir/output/stdout

#sudo python $curdir/mysqltest.py $curdir
sudo cgcreate -g cpu:cpu_limit_oltp
mysqld_pid=$(ps -aux | grep mysqld | grep -v grep | awk '{print $2}')
sudo cgclassify -g cpu:cpu_limit_oltp $mysqld_pid

read -p $'please enter [Min_cpu_limit] [Max_cpu_limit] [Step]:  (both included; Default: 100 100 1\n' lmin lmax lstep
if [ -z "$lmin" ];
then
	lmin=100000
else
	lmin=$(($lmin*1000))
fi

if [ -z "$lmax" ];
then
	lmax=100000
else
	lmax=$(($lmax*1000))
fi

if [ -z "$lstep" ];
then
	lstep=1000
else
	lstep=$(($lstep*1000))
fi

for limit in $(seq $lmin $lstep $lmax)
do
	sudo cgset -r cpu.cfs_quota_us=$limit cpu_limit_oltp
	sleep 30s
	echo -e "\e[32mLimit: " $(($limit/1000)) "% test END......\e[0m" | tee -a $curdir/output/stdout
done

sudo cgset -r cpu.cfs_quota_us=-1 cpu_limit_oltp

pid=$(ps -aux | grep sysbench | grep -v grep | grep -v cgexec | awk '{print $2}')
sudo kill -9 $pid
#perf_pid=$(ps -aux | grep perf | grep -v grep | awk '{print $2}')
#sudo kill -SIGTERM $perf_pid
