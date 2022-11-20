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

for core_id in $(seq 1 $num_proc)
do
	sudo cgcreate -g cpuset:small$core_id
	sudo cgset -r cpuset.cpus=$(($core_id+13)) -r cpuset.mems=0 small$core_id
done


for core_id in $(seq 1 $num_proc)
do
	cgexec -g cpuset:small$core_id $curdir/bp_simulator -m $pattern -b 1 -s 1024 -400000 &
done
cgexec -g cpuset:small $curdir/multichase/multiload > $curdir/output/stdout
#cgexec -g cpuset:small /usr/local/bin/sysbench memory --memory-block-size=4K --memory-total-size=40G --num-threads=4 run | grep "MiB/sec" >> $curdir/output/stdout

sudo $curdir/pgkill.sh bp_simulator
