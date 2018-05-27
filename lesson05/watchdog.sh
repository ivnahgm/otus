#!/bin/bash


pre_exit () {

    local job_pid=$1
    local job_name=$2
    local sender=$3
    local rcpt=$4

    kill -9 $job_pid
    echo -e "FROM: $sender\nSUBJECT: Stop job!\njob $job_name was stopped" \
          | sendmail $rcpt
    exit
}

watched=$1
sender=watchdog@otuslinux.localdomain
rcpt=root@otuslinux.localdomain

$watched&

trap 'pre_exit $! $watched $sender $rcpt' SIGINT SIGHUP SIGTERM SIGQUIT

while true
do
    if [ ! -d /proc/$! ]; then
        trap --
        $watched&
        trap 'pre_exit $! $watched $sender $rcpt' SIGINT SIGHUP SIGTERM SIGQUIT
    fi
sleep 10
done
