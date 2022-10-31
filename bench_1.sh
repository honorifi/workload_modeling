echo mark3
cd /home/$USER/STREAM
sudo cgset -r cpuset.cpus=1 -r cpuset.mems=0 small
cnt=1
while [ True ];do
	sudo cgexec -g cpuset:small ./stream_c.exe > /dev/null
	echo "test run " $cnt " times"
	cnt=`expr $cnt + 1`
done;

