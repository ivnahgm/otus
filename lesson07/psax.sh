#!/usr/bin/bash

PROC=/proc
CLKTCK=$(getconf CLK_TCK)


get_pid () {
    echo $(basename $1)
}

get_tty () {
    if [[ ! -r $1/fd || -z $(ls -l $1/fd/0 | grep pts) ]]; then
        tty="?"
    else
        tty=$(ls -l $1/fd/0  | awk -F" -> " '{print $2}' | sed 's/\/dev\///')
    fi
    
    echo $tty
}

get_stat () {
    stat=$(awk 'NR==3 {print $2}' $1/status)
    check_priority=$(awk '{print $18}' $1/stat)
    check_page_locked=$(awk '/VmLck/ {print $2}' $1/status)
    check_session_leader=$(awk '{print $6}' $1/stat)
    check_multithreded=$(awk '{print $20}' $1/stat)
    check_foreground=$(awk '{print $8}' $1/stat)

    if [[ $check_priority == "0" ]]; then stat=$stat"<"; fi
    if [[ $check_priority > 20 ]]; then stat=$stat"N"; fi
    if [[ ! -z $check_page_locked && $check_page_locked != "0" ]]; then stat=$stat"L"; fi
    if [[ $check_session_leader == $(basename $1) ]]; then stat=$stat"s"; fi
    if [[ $check_multithreded > 1 ]]; then stat=$stat"l"; fi
    if [[ ! -z $check_foreground && $check_foreground != "-1" ]]; then stat=$stat"+"; fi
    stat=$stat"$check_high_priority"

    echo $stat
}

get_time () {
    echo $(awk -v clktck=$2 '{printf "%2d:%02d",($14+$15)/clktck/60,($14+$15)/clktck%60}' $1/stat)
}

get_cmd () {
    if [[ -f $1/cmdline ]]; then
        cmd=$(awk '{print $0}' $1/cmdline | sed 's/\x0/ /g')
        if [[ -z $cmd ]]; then
            cmd="[$(awk '{print $0}' $1/comm)]"
        fi
    fi

    echo $cmd

}

print_result () {
    for i in $1/*/; do
        [[ $(basename $i) =~ ^[0-9] ]] && \
        echo $(get_pid $i)\; $(get_tty $i)\; $(get_stat $i)\; $(get_time $i $2)\; $(get_cmd $i)
    done
}

get_shrinked_tty_width () {
    echo $(tput cols | awk -v shrink=$1 '{print $1-shrink}')
}

print_result $PROC $CLKTCK 2>/dev/null | sort -n | \
awk -F";" -v colwidth=$(get_shrinked_tty_width 26) \
'BEGIN {printf "%5s %-9s%-5s%6s %s\n","PID","TTY","STAT","TIME","COMMAND"}; \
{printf "%5s%-9s%-5s%7s%.*s\n",$1,$2,$3,$4,colwidth,$5}'