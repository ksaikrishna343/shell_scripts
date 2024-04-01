#!/bin/bash
#This script is used to tar.gz the derectories which were created 30+ days ago

#Target directory
TARGET_DIRECTORY=/var/log/syslog/remote/CEBESVC-Ba5ZCP3

#use the find command to locate directories older than 30 days
DIR_LIST=`find $TARGET_DIRECTORY/* -type d -mtime +30|xargs -I {}  basename {}`

#creating archive tar.gz
for i in $DIR_LIST;
do cd $TARGET_DIRECTORY && tar -zcvf $i.tar.gz $i && rm -rf $i;
done
