if [ -z "$1" ];
then
	sysbench /home/kongxc/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --oltp-test-mode=complex --oltp-tables-count=10 --oltp-table-size=1000000 --threads=8 --oltp-read-only=off --time=1200 --report-interval=10 prepare
elif [ $1 == "clean" ]
then
	sysbench /home/kongxc/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --oltp-tables-count=10 cleanup
elif [ $1 == "mysql" ]
then
	read -p $'choose operation: start/stop/restart/status\t' op
	service mysqld $op
	if [ $op == "start" ] || [ $op == "restart" ]
	then
		pid=$(ps -aux | grep mysqld | grep -v grep | awk '{print $2}')
		sudo taskset -p 0xffff $pid
	fi
elif [ $1 == "help" ]
then
	echo $'./prepare:\t\tmysql data preparation'
	echo $'./prepare clean:\tmysql data cleanup'
else
	echo "command: \""$1"\" not found..."
	echo $"try \"./prepare.sh help\" for help"
fi

