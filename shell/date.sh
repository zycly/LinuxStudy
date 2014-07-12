#!/bin/bash

a=$1
b=$2

expr $a + 0 2>&1
[ $? -ne 0 ] && exit 
expr $b + 0 2>&1
[ $? -ne 0 ] && exit

echo "a-b=$(($a-$b))"
echo "a+b=$(($a+$b))"
echo "a*b=$(($a*$b))"
echo "a/b=$(($a/$b))"
echo "a**b=$(($a**$b))"
echo "a%b=$(($a%$b))"
