if [ -z "$1" ];
then
	limit=100000
else
	limit=$1
fi

sudo cgcreate -g cpu:cgpressure

sudo cgset -r cpu.cfs_quota_us=$limit cgpressure


while ((1))
do
	sudo cgexec -g cpu:cgpressure /home/kongxc/autotool/STREAM/stream_c.exe > /home/kongxc/autotool/output/limit &

	pid=$(ps -ef | grep stream_c.exe | grep -v grep | grep -v cgexec | awk '{print $2}')

	sudo cgclassify -g cpu:cgpressure $pid

	tail --pid=$pid -f /dev/null
	echo 'repeat stream_c.exe'
done
