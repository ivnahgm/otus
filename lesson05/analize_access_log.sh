#!/bin/bash

ACCESS_LOG_FILE=$1
MESSAGE_SUBJECT="Unique user-agents at last minutes"
SENDER="analize_httpd@otuslinux.localdomain"
RCPT="root@otuslinux.localdomain"


while true
do
    last_minute_time=`date -d @$(($(date +%s)-60)) +%H:%M`
    line_number="$(grep -n -m 1 :$last_minute_time: $ACCESS_LOG_FILE | awk -F: '{print $1}')"
    
    MESSAGE_BODY="$(awk -F\" "NR>=$line_number {print \$6}" $ACCESS_LOG_FILE | sort | uniq -c)"

    echo -e "FROM: $SENDER\nSUBJECT: $MESSAGE_SUBJECT\n$MESSAGE_BODY" | \
            sendmail $RCPT

    sleep 60
done
