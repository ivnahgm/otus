#!/bin/bash


LOGFILE=$1
KEYWORD=$2
SLEEPPAUSE=$3


while true
do
    found_lines="$(awk -v pattern=$KEYWORD '$0~pattern{$1="";print $0}' $LOGFILE)"
    if [ -n "$found_lines" ]; then
        echo "Found $KEYWORD in $LOGFILE:"
        echo $found_lines
    fi

    sleep $SLEEPPAUSE
done