echo 'this is tmp test for bp_simulator...'

curdir=$(cd $(dirname $0); pwd)

sudo cgcreate -g cpuset:small
sudo cgset -r cpuset.cpus=7-10 -r cpuset.mems=0 small

read -p $'please input num_proc [default: 1]\n' num_proc
if [ -z "$num_proc" ];
then
    num_proc=1
fi
read -p $'please input IO pattern [Seq\Random default: Seq]\n' pattern
if [ -z "$pattern" ];
then
    pattern="Seq"
fi

for core_id in $(seq 1 $num_proc)
do
	sudo cgcreate -g cpuset:small$core_id
	sudo cgset -r cpuset.cpus=$(($core_id+10)) -r cpuset.mems=0 small$core_id
done


for core_id in $(seq 1 $num_proc)
do
    cgexec -g cpuset:small$core_id $curdir/bp_simulator -m $pattern -s 1024 -40000 &
done
cgexec -g cpuset:small $curdir/multichase/multiload > $curdir/output/stdout
cgexec -g cpuset:small /usr/local/bin/sysbench memory --memory-block-size=4K --memory-total-size=40G --num-threads=4 run | grep "MiB/sec" >> $curdir/output/stdout

sudo $curdir/pgkill.sh bp_simulator