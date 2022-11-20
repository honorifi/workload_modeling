echo 'this is tmp test for bp_simulator...'

curdir=$(cd $(dirname $0); pwd)

sudo cgcreate -g cpuset:small
sudo cgset -r cpuset.cpus=10-13 -r cpuset.mems=0 small

if [ -z $1 ];
then
	read -p $'please input num_proc [default: 1]\n' num_proc
	# num_proc=1
else
	num_proc=$1
fi

if [ -z $2 ];
then
	read -p $'please input IO pattern [Seq\Random\Interval default: Random]\n' pattern
	# pattern="Random"
else
	pattern=$2
fi


sudo cgcreate -g cpuset:small_bp
if [ $num_proc -gt 1 ]
then
    sudo cgset -r cpuset.cpus=14-$(($num_proc+13)) -r cpuset.mems=0 small_bp
else
    sudo cgset -r cpuset.cpus=14 -r cpuset.mems=0 small_bp
fi

cgexec -g cpuset:small_bp $curdir/bp_simulator-openmp -m $pattern -T $num_proc -s 1024 -40000 &

cgexec -g cpuset:small $curdir/multichase/multiload > $curdir/output/stdout
#cgexec -g cpuset:small /usr/local/bin/sysbench memory --memory-block-size=4K --memory-total-size=40G --num-threads=4 run | grep "MiB/sec" >> $curdir/output/stdout

sudo $curdir/pgkill.sh bp_simulator-openmp
