#!/bin/bash

function process () {
    ionice -c $1 -n $2 dd if=/dev/urandom of=$4 bs=10M count=$3 |& tail -n 1 | \
    awk -v class=$1 -v level=$2 '{print "Process with class="class", and level="level": "$0}'
}

while [[ -n $1 ]]; do
    case "$1" in 
        "--count") COUNT=$2; shift 2;;
        "--class1") CLASS1=$2; shift 2;;
        "--class2") CLASS2=$2; shift 2;;
        "--level1") LEVEL1=$2; shift 2;;
        "--level2") LEVEL2=$2; shift 2;;
        *) echo "Invalid option $1"; exit 1;;
    esac    
done

if [[ -z $COUNT ]]; then COUNT=10; fi
if [[ -z $CLASS1 ]]; then CLASS1=0; fi
if [[ -z $CLASS2 ]]; then CLASS2=0; fi
if [[ -z $LEVEL1 ]]; then LEVEL1=7; fi
if [[ -z $LEVEL2 ]]; then LEVEL2=7; fi

OUTFILE1=ionice_script_out_file_1
OUTFILE2=ionice_script_out_file_2

process $CLASS1 $LEVEL1 $COUNT $OUTFILE1 & 
process $CLASS2 $LEVEL2 $COUNT $OUTFILE2 &

wait

rm $OUTFILE1 $OUTFILE2