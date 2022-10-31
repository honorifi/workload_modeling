if [ ! $1 ];
then
	echo "" > /sys/fs/cgroup/cpu/cpu_test/tasks
else
	echo $1 >> /sys/fs/cgroup/cpu/cpu_test/tasks
fi
