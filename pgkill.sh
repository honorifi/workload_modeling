if [ "$1" ];
then
    pid_all=$(ps -aux | grep $1 | grep -v grep | awk '{print $2}')
    for _pid in ${pid_all}
    do
        sudo kill -9 $_pid > /dev/null 2>&1
    done
fi