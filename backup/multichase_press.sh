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


sudo cgcreate -g cpuset:small1
sudo cgset -r cpuset.cpus=17-20 -r cpuset.mems=1 small1
sudo cgcreate -g cpuset:small2
sudo cgset -r cpuset.cpus=21-24 -r cpuset.mems=2 small2
sudo cgcreate -g cpuset:small3
sudo cgset -r cpuset.cpus=25-28 -r cpuset.mems=3 small2
sudo cgcreate -g cpuset:small4
sudo cgset -r cpuset.cpus=29-32 -r cpuset.mems=4 small2
read -p $'please enter the number of pressure process: (do not exceed 4, default: 1)\n' num_proc
if [ -z "$num_proc" ];
then
	num_proc=1
fi

sudo cgcreate -g cpu:cgpressure
echo "" > $curdir/output/limit

echo -e "\e[32mSTREAM START......\e[0m" | tee -a $curdir/output/stdout


for limit in $(seq $limit_start $step $limit_end)
do
	sudo cgset -r cpu.cfs_quota_us=$limit cgpressure

	start_time=$(date +%s)
	cost=0
	while(($cost<30))
	do
		if (( $cost == 0 ))
		then
			sudo cgexec -g cpuset:small1 $curdir/multichase/multiload >> $curdir/output/limit &
		else
			sudo cgexec -g cpuset:small1 $curdir/multichase/multiload > /dev/null &
		fi
		ps > /dev/null
		pid=$(ps -aux | grep multiload | grep -v grep | grep -v cgexec | awk '{print $2}')
		#echo $(ps -aux | grep multiload | grep -v grep)
		echo "PID: "$pid
		#sudo cgclassify -g cpu:cgpressure $pid
		
	        sudo cgexec -g cpuset:small2 $curdir/multichase/multiload > /dev/null &
                ps > /dev/null
		echo $(ps -ef | grep multiload | grep -v grep)
		pid2=$(ps -aux | grep multiload | grep -v grep | grep -v cgexec | awk '{print $2}')
                
                echo "PID: "$pid2
                sudo cgclassify -g cpu:cgpressure $pid2	
		
		pid2=$(echo $pid2 | awk '{print $2}')
		tail --pid=$pid2 -f /dev/null		

		tail --pid=$pid -f /dev/null
		
		end_time=$(date +%s)
		cost=$[ $end_time - $start_time ]
	done
	#echo $(ps -aux | grep stream_c.exe | grep -v grep | grep -v cgexec)

	echo -e "\e[32mLimit: " $(($limit/1000)) "% test END......\e[0m" | tee -a $curdir/output/stdout
done

echo -e "\e[32mSTREAM END......\e[0m" | tee -a $curdir/output/stdout
