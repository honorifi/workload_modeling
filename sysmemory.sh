if [ -z "$1" ];
then
	limit_start=100000
else
	limit_start=$(($1*1000))
fi

if [ -z "$2" ];
then
	limit_end=100000
else
	limit_end=$(($2*1000))
fi

if [ -z "$3" ];
then
	step=1000
else
	step=$(($3*1000))
fi

if [ -z "$4" ];
then
	curdir=$(cd $(dirname $0); pwd)
else
	curdir=$4
fi

read -p $'please enter the number of pressure process: (better not exceed 4, default: 1)\n' num_proc
if [ -z "$num_proc" ];
then
        num_proc=1
fi
if (( $num_proc > 1 ))
then
        para_proc=$(($num_proc-1))
else
	para_proc=1
fi

for core_id in $(seq 1 $num_proc)
do
	sudo cgcreate -g cpuset:small$core_id
	sudo cgset -r cpuset.cpus=$(($core_id+16)) -r cpuset.mems=$(($core_id%4)) small$core_id
done
#sudo cgcreate -g cpuset:small2
#sudo cgset -r cpuset.cpus=18 -r cpuset.mems=1 small2
#sudo cgcreate -g cpuset:small3
#sudo cgset -r cpuset.cpus=19 -r cpuset.mems=2 small3
#sudo cgcreate -g cpuset:small4
#sudo cgset -r cpuset.cpus=20 -r cpuset.mems=2 small4

sudo cgcreate -g cpu:cgpressure
echo "" > $curdir/output/limit

echo -e "\e[32mSTREAM START......\e[0m" | tee -a $curdir/output/stdout

mysqld_pid=$(ps -aux | grep mysqld | grep -v grep | awk '{print $2}')
sudo perf stat -p $mysqld_pid -e L1-dcache-load,L1-dcache-load-miss,ll_cache,ll_cache_miss,instructions -- sleep 10 > $curdir/output/perfout 2>&1 &

for limit in $(seq $limit_start $step $limit_end)
do
	sudo cgset -r cpu.cfs_quota_us=$(($limit*$para_proc)) cgpressure

	start_time=$(date +%s)
	cost=0
	while(($cost<30))
	do
		if (( $cost == 0 ))
		then
			sudo cgexec -g cpuset:small1 /usr/local/bin/sysbench memory --memory-block-size=4K --memory-total-size=30G --num-threads=1 run >> $curdir/output/limit &
		else
			sudo cgexec -g cpuset:small1 /usr/local/bin/sysbench memory --memory-block-size=4K --memory-total-size=30G --num-threads=1 run > /dev/null &
		fi
		ps > /dev/null
		pid0=$(ps -aux | grep sysbench | grep memory | grep -v grep | grep -v cgexec | awk '{print $2}')
		
		for i in $(seq 2 $num_proc)
		do
			sudo cgexec -g cpuset:small$i $curdir/multichase/multiload > /dev/null &		
		done

		#echo $(ps -ef | grep multiload | grep -v grep)
		ps > /dev/null
		pidl=$(ps -aux | grep multiload | grep -v grep | grep -v cgexec | awk '{print $2}')
                pid=$pid0' '$pidl
                echo "PID0: "$pid0"; PIDL: "$pidl
                sudo cgclassify -g cpu:cgpressure $pidl
	
		for spid in ${pid}
		do
			tail --pid=$spid -f /dev/null
		done
		
		end_time=$(date +%s)
		cost=$[ $end_time - $start_time ]
	done
	#echo $(ps -aux | grep stream_c.exe | grep -v grep | grep -v cgexec)

	echo -e "\e[32mLimit: " $(($limit/1000)) "% test END......\e[0m" | tee -a $curdir/output/stdout
done

echo -e "\e[32mSTREAM END......\e[0m" | tee -a $curdir/output/stdout
