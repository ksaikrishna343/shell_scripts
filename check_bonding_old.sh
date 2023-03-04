#!/bin/bash
# This script is used to check the bonding configuration status

#BOND_DIR=/proc/net/bonding
BOND_DIR=/var/tmp
BOND_FILES=`ls -lrt $BOND_DIR| grep bond | awk '{print $9}'|sort`
echo $BOND_FILES

for i in $BOND_FILES
do
  echo;echo "Bonding name: $i"
#  cat $BOND_DIR/$i | egrep "Bonding Mode|Active|Interface|MII Status|Speed"
ETH_NAME=`cat $BOND_DIR/$i | grep "Slave Interface: "| cut -d ":" -d ' ' -f3`
ETH_COUNT=`cat $BOND_DIR/$i | grep "Slave Interface: "| cut -d ":" -d ' ' -f3|wc -l`
  if [[ $ETH_COUNT == 2 ]]
  then 
    echo "$i has below 2 interfaces." 
    echo "$ETH_NAME"
  else
    echo "$i has below 1 interface."
    echo "$ETH_NAME"
  fi
echo
  if [ `grep -c down $BOND_DIR/$i` -ge 1 ]
  then
    echo "$(grep -B1 down $BOND_DIR/$i | awk -F': ' '{ print $2 }') is down"  
  fi
done

