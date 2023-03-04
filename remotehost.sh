#!/bin/bash

#To test on remote host

for i in ubuntu18 node1
do
 ssh $i uname -a
done
