#!/bin/bash

set -e

file1="/home/zyc/Desktop/git/shell/test1"
file2="/home/zyc/Desktop/git/shell/test2"
file="/home/zyc/Desktop/git/shell/tmp"

[ ! -f $file ] && touch $file || >$file

cat $file1 | while read line1
do
	Line1=`echo $line1 | awk '{print $1}'`	
        cat $file2 | while read line2
	do
		Line2=`echo $line2 | awk '{print $1}'`	
		if [ "$Line1" == "$Line2" ]
		then
			echo -n $line1 >>$file
			echo "$line2" | awk '{print " "$2}' >>$file			
		fi	
	done
done 

cat $file | sort -nrk 1

rm $file

exit 0
