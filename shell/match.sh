#!/bin/bash

set -e

read -p "please input the IP:" IP

echo $IP | awk -v ip=$IP '{host[$1]=$2} END{print host[ip]}' /home/zyc/Desktop/hosts

egrep "$IP" ~/Desktop/hosts | awk '{print $2}'

awk 'BEGIN{var="'$1'"} {if(var==$1)print $2}' ~/Desktop/hosts

awk '{if($1 ~/'$1'/)print $2}' ~/Desktop/hosts



