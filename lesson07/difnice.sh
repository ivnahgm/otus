#!/bin/bash

function process () {
    nice -n $2 dd if=/dev/urandom of=/dev/null bs=10M count=$1 |& tail -n 1 | \
    awk -v nice_value=$2 '{print "Process with NICE="nice_value": "$0}'
}

if [[ -z "$1" ]]; then
    COUNT=5
else
    COUNT=$1
fi

if [[ -z $2 ]]; then
    NICE1=17
else
    NICE1=$2
fi

if [[ -z $3 ]]; then
    NICE2=16
else
    NICE2=$3
fi


process $COUNT $NICE1 & 
process $COUNT $NICE2 &

wait