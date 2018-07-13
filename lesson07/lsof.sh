#!/usr/bin/bash

PROC=/proc

function get_command () {
    echo $(awk '{print $0}' $1/comm)
}

function get_user () {
    echo $(ls -dl $1 | awk '{print $3}')
}

function get_fd () {
    PROCESS=$1
    FD=$2
    MODEFLAG=$(awk '{if ($1=="flags:") {print $2}}' $PROCESS/fdinfo/$2 | tail -c 2)
    case "$MODEFLAG" in
    '0')
        MODELITERAL="r"
        ;;
    '1')
        MODELITERAL="w"
        ;;
    '2')
        MODELITERAL="u"
    esac
    echo $FD$MODELITERAL
}

function get_device () {
    DEVICES=$(awk -v FILE_NAME="$2" '$0~FILE_NAME {print $4}' $1/maps | \
    head -1 | \
    awk -F":" '{printf "%d,%d",strtonum("0x" $1),strtonum("0x" $2)}')
    echo $DEVICES
}

function get_sizeoff () {
    echo $([[ -r $1 ]] && ls -l $1 | awk '{print $5}')
}

function get_sizeoff_dir () {
    echo $([[ -r $1 ]] && ls -ld $1 | awk '{print $5}')
}

function get_node () {
    echo $(awk -v FILE_NAME="$2" '$0~FILE_NAME {print $5}' $1/maps | head -1)
}

function get_name () {
    echo $(readlink $1)
}

function print_cwd_rtd_txt () {
    COMMAND=$(get_command $1)
    PID=$(basename $1)
    TID="-"
    USER=$(get_user $1)
    NAME=$(readlink $1/$2)
    if [[ $NAME ]]; then
        DEVICE=$(stat -c %D $NAME)
        case $2 in
        "cwd")
            FD="cwd"
            TYPE="DIR"
            SIZEOFF=$(get_sizeoff_dir $NAME)
            NODE=$(ls -id $NAME | awk '{print $1}')
            ;;
        "root")
            FD="rtd"
            TYPE="DIR"
            SIZEOFF=$(get_sizeoff_dir $NAME)
            NODE=$(ls -id $NAME | awk '{print $1}')
            ;;
        "exe")
            FD="txt"
            TYPE="REG"
            SIZEOFF=$(get_sizeoff $NAME)
            NODE=$(get_node $1 $(echo $NAME | awk '{print $1}'))
            ;;
        esac
        echo $COMMAND $PID $TID $USER $FD $TYPE $DEVICE $SIZEOFF $NODE $NAME
    fi
}

function print_maped_file () {
    COMMAND=$(get_command $1)
    PID=$(basename $1)
    TID="-"
    USER=$(get_user $1)
    TYPE="REG"
    NAME=$2
    FD="mem"
    DEVICE=$(get_device $1 $NAME)
    SIZEOFF=$(get_sizeoff $2)
    NODE=$(get_node "$1" $NAME)
    echo $COMMAND $PID $TID $USER $FD $TYPE $DEVICE $SIZEOFF $NODE $NAME
}

function print_fd_file () {
    COMMAND=$(get_command $1)
    PID=$(basename $1)
    TID="-"
    USER=$(get_user $1)
    FD=$(get_fd $1 $(basename $2))
    DEVICEID=$(awk '$1=="mnt_id:" {print $2}' $1/fdinfo/$(basename $2))
    DEVICE=$(awk -v id=$DEVICEID '$1==id {print $3}' $1/mountinfo | awk -F":" '{print $1","$2}')  
    SIZEOFF=$(awk 'NR==1 {print $2}' $1/fdinfo/$(basename $2))
    NAME=$(get_name $2)

    if [[ $(echo $NAME | cut -b1) == "/" ]]; then
        NODE=$(stat -c %i $NAME)
        if [[ -d $NAME ]]; then
            TYPE="DIR"
        elif [[ $(ls -l $NAME | cut -b1) == "c" ]]; then
            TYPE="CHR"
            DEVICE=$(stat -c %t,%T $NAME)
        elif [[ -f $NAME ]]; then
            TYPE="REG"
        else
            TYPE="?"
        fi

    elif [[ $(echo $NAME | awk -F":" '{print $1}') == "socket" ]]; then
        TYPE="unix"
        NODE=$(echo $NAME | awk -F":" '{print $2}' | sed s/[][]//g)
        NAME=$(echo $NAME | awk -F":" '{print $1}')

        if [[ $(grep $NODE $1/net/unix) ]]; then
            DEVICE=$(awk -v NODE=$NODE '$7==NODE {print $1}' $1/net/unix | sed s/://g)
        elif [[ $(grep $NODE $1/net/tcp) ]]; then
            TYPE="IPv4"
            DEVICE=$NODE
            NODE="TCP"
        elif [[ $(grep $NODE $1/net/udp) ]]; then
            TYPE="IPv4"
            DEVICE=$NODE
            NODE="UDP"
        elif [[ $(grep $NODE $1/net/tcp6) ]]; then
            TYPE="IPv6"
            DEVICE=$NODE
            NODE="TCP"
        elif [[ $(grep $NODE $1/net/udp6) ]]; then
            TYPE="IPv6"
            DEVICE=$NODE
            NODE="TCP"
        fi

        if [[ $SIZEOFF == "0" ]]; then
            SIZEOFF="0t0"
        fi

    elif [[ $(echo $NAME | awk -F":" '{print $1}') == "anon_inode" ]]; then
        TYPE="a_inode"
        DEVICE="?"
        NODE="?"
        NAME=$(echo $NAME | awk -F":" '{print $2}')

    elif [[ $(echo $NAME | awk -F":" '{print $1}') == "pipe" ]]; then
        TYPE="FIFO"
        DEVICE="?"
        SIZEOFF=$(awk 'NR==1 {print $2}' $1/fdinfo/$(basename $2))
        NODE=$(echo $NAME | awk -F":" '{print $2}' | sed s/[][]//g)
        NAME=$(echo $NAME | awk -F":" '{print $1}')

    else
            TYPE="?"
            NODE="?"
    fi
            echo $COMMAND $PID $TID $USER $FD $TYPE $DEVICE $SIZEOFF $NODE $NAME
}

function print_result () {
    for i in $(find $1 -maxdepth 1); do
        if [[ $(basename $i) =~ ^[0-9] && -r $i ]]; then
            for j in "cwd" "root" "exe"; do
                print_cwd_rtd_txt $i $j
            done

            if [[ -r $i/map_files ]]; then
                for k in $(find $i/map_files/ | xargs readlink | uniq); do
                    print_maped_file $i $k
                done
            fi

            if [[ -r $i/fd ]]; then
                for l in $i/fd/*; do
                    print_fd_file $i $l
                done
            fi
        fi
    done
}

print_result $PROC 2>/dev/null | \
awk 'BEGIN {printf "%-10s%5s%6s%10s%5s%10s%19s%10s%11s %-s\n","COMMAND","PID","TID","USER", \
"FD", "TYPE", "DEVICE", "SIZE/OFF", "NODE", "NAME"}; \
{printf "%-10s%5s%6s%10s%5s%10s%19s%10s%11s %-s\n",substr($1,1,9),$2,$3,$4,$5,$6,$7,$8,$9,$10}'