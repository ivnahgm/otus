#!/bin/bash


QUOTEFILE=$1
LOGFILE=$2
SLEEPPAUSE=$3

get_random_quote () {
    FILE=$1

    quotes="$(wc -l $FILE | awk '{print $1}')"
    randomize="$(shuf -i 0-$quotes -n 1)"
    randomquote="$(head -$randomize $1 | tail -1)"

    echo $randomquote
}

while true
do
    current_time="$(date +%F-/%T/)"
    get_random_quote $QUOTEFILE | \
        awk -F" ; " -v time=$current_time '{print time "  Once " $1 " said: " $2}' \
        >> $LOGFILE

    sleep $SLEEPPAUSE
done
