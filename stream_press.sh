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

curdir=$4

sudo cgcreate -g cpuset:small
sudo cgset -r cpuset.cpus=1-16 -r cpuset.mems=1 small
sudo cgcreate -g cpu:cgpressure
sudo cgexec -g cpuset:small /home/kongxc/autotool/STREAM/stream_c.exe > /home/kongxc/autotool/output/limit &
ps > /dev/null
pid=$(ps -aux | grep stream_c | grep -v grep | grep -v cgexec | awk '{print $2}')
echo "PID: " $pid
sudo cgclassify -g cpu:cgpressure $pid
sleep 3s	#wait untill stream is stable
echo -e "\e[32mSTREAM START......\e[0m" | tee -a $curdir/output/stdout

for limit in $(seq $limit_start $step $limit_end)
do
	sudo cgset -r cpu.cfs_quota_us=$limit cgpressure
	#echo $(ps -aux | grep stream_c.exe | grep -v grep | grep -v cgexec)
	sleep 30s
	echo -e "\e[32mLimit: " $(($limit/1000)) "% test END......\e[0m" | tee -a $curdir/output/stdout
done
sudo kill -9 $pid
echo -e "\e[32mSTREAM END......\e[0m" | tee -a $curdir/output/stdout
