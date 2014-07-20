#!/bin/bash

set -e 

user="root"
password="901102"
database="study"
table="information"

[ $# -ne 1 ] && echo "Usage:you should choose the input file!"

mysql -u"$user" -p"$password" <<EOF
create database $database;
EOF

if [ $? -eq 0 ] 
then
	echo "Create database Success!"  
else
	echo "DB is already exists"
	exit
fi

mysql -u$user -p$password <<EOF &>/dev/null
use $database;
CREATE TABLE  $table(
id int,
name varchar(20),
age int,
primary key(id)
);
EOF

[ $? -eq 0 ] && echo "create table success" || echo "create failure"

date=$1
while read line
do
	query=`echo $line | awk 'BEGIN{FS=","}{print "\042"$1"\042"",""\042"$2"\042"",""\042"$3"\042"}'`
	mysql -u$user -p$password <<EOF 
	use $database;
	INSERT into $table values($query);
EOF
done<$date
echo "write to db success"
exit 0
