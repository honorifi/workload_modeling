if [ ! $1 ];
then
	quota_us=-1
else
	quota_us=$1
fi

sudo cgcreate -g cpuset:small
sudo cgcreate -g cpuset:memory_bw_control
sudo cgset -r cpuset.cpus=1 -r cpuset.mems=0 small
sudo cgset -r cpuset.cpus=0 -r cpuset.mems=0 memory_bw_control

script_dir=$(cd $(dirname $0);pwd)

cd /sys/fs/cgroup/cpu
mkdir cpu_test
sudo echo $quota_us > ./cpu_test/cpu.cfs_quota_us

cd /sys/fs/cgroup/cpuset/memory_bw_control
sudo cgexec -g cpuset:memory_bw_control python $script_dir/pybench.py $script_dir
