if [ ! $1 ];
then
	echo "-1" > /sys/fs/cgroup/cpu/cpu_test/cpu.cfs_cpu_quota_us
else
	echo $1 > /sys/fs/cgroup/cpu/cpu_test/cpu.cfs_cpu_quota_us
fi
