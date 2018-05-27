#!/bin/bash


user_agents=(
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1 Safari/605.1.15"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36"
"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0"
"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
)

LOCK_FILE="/tmp/query_script_lock"

get_random_number () {
    start=$1
    end=$2
    length=$3

    local result=`cat /dev/urandom | \
                  tr -dc $start-$end | \
                  fold -w $length | \
                  head -n 1`
    echo $result
}

if [ ! -f $LOCK_FILE ]; then
    touch $LOCK_FILE
else
    exit
fi

count=0
until [ $count -eq 1000 ]
do
    curl -A "${user_agents[$(get_random_number 0 4 1)]}" http://127.0.0.1 >/dev/null 2>&1
    (( count++ ))
done

rm $LOCK_FILE
