#!/bin/bash

today=$(date +"%Y%m%d")
now=$(date +%T)

# get last commit date
lastCommitDate=$(date -d @$(git log -1 --format="%at" 2>/dev/null) +%Y%m%d 2>/dev/null)
OUT=$?

veryFirstRun=false

# if not present
if [ $OUT != 0 ]; then
    # set date 1970.01.01
    lastCommitDate="19691231"
    veryFirstRun=true
fi

nextDay=$lastCommitDate

while true; do
    nextDay=$(date +"%Y%m%d" --date="$nextDay + 1 day")

    # check today
    if [ $today -lt $nextDay ]; then
        date  +"%Y%m%d" -s "$today"
        exit
    fi

    year=$(echo $nextDay | cut -c 1-4)
    month=$(echo $nextDay | cut -c 5-6)
    day=$(echo $nextDay | cut -c 7-8)

    #set date
    if $veryFirstRun ; then
       date -s "1970-01-01 00:00:01 UTC"
    else
       date  +"%Y%m%d" -s "$nextDay" >/dev/null
    fi

    #set time 0:random:random
    randomSeconds=$(( $RANDOM % 60 ))
    if [ $randomSeconds -eq 0 ]; then
        randomSeconds=1
    fi
    randomMinutes=$(( $RANDOM % 5 ))
    randomSeconds=$(printf "%.2d" $randomSeconds)
    randomMinutes=$(printf "%.2d" $randomMinutes)
    theTime="00:$randomMinutes:$randomSeconds"
    if $veryFirstRun ; then
        echo "init"
    else
        date +%T -s "$theTime" >/dev/null
    fi

    #modify file
    readableDate="$year.$month.$day."
    sed -i "s/\*\*[^*]*\*\*/**$readableDate**/" readme.md
    echo $readableDate > current-date

    date

    #commit
    if $veryFirstRun ; then
        #git init
        git add current-date readme.md
        git commit -m "Initial commit"
        #git remote add origin git@github.com:sarkiroka/current-date.git
    else
        git add -u
        if [ "$nextDay" -eq "19860427" ]; then
            git commit -m "Cahnge the current date"
        else
            git commit -m "Change the current date"
        fi
    fi
    veryFirstRun=false

done

date  +"%Y%m%d" -s "$today" >/dev/null
date +%T -s "$now" >/dev/null
