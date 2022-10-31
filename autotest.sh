read -p $'please enter workload running instruction: [default: stream]\n' script_dir

if [ -z "$script_dir" ];
then
	script_dir="./STREAM/stream_c.exe"
fi
echo $'\33[31minstruction: \33[0m' $script_dir $'\t\t\33[32mnum_proc: \33[0m' $num_proc

curdir=$(cd $(dirname $0); pwd)


echo "" > $curdir/output/stdout
#sudo cgcreate -g cpuset:back_mission
#sudo cgset -r cpuset.cpus=1-10 -r cpuset.mems=1 back_mission
/usr/local/bin/sysbench /home/kongxc/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --oltp-test-mode=complex --oltp-tables-count=10 --oltp-table-size=1000000 --threads=10 --time=1200 --report-interval=10 run >> $curdir/output/stdout &

#echo "" > $curdir/output/stdout
#sysbench /home/kongxc/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --oltp-test-mode=complex --oltp-tables-count=10 --oltp-table-size=1000000 --threads=10 --time=120 --report-interval=10 run >> $curdir/output/stdout

sudo python $curdir/mysqltest.py $curdir

pid=$(ps -aux | grep sysbench | grep -v grep | grep -v cgexec | awk '{print $2}')
sudo kill -9 $pid
#perf_pid=$(ps -aux | grep perf | grep -v grep | awk '{print $2}')
#sudo kill -SIGTERM $perf_pid
