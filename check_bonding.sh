#!/bin/bash
# This script is used to check the bonding configuration status

BOND_DIR=/proc/net/bonding
#BOND_DIR=/var/tmp

if [[ -d $BOND_DIR ]]
then
   echo "Bonding configuration found on server. Hence proceeding.."
else
   echo "Bonding not confifured on the server"
fi

ls -l $BOND_DIR|grep bond| awk '{print $9}'|sort|tr '\t' '\n' > /tmp/bondfiles
#cat /tmp/bondfiles
echo
echo "Below bonding configuration found in server"

for x in `cat /tmp/bondfiles`
do
  echo `cd $BOND_DIR; ls -l $x|awk '{print $9}'`
done

##############################################################

for i in `cat /tmp/bondfiles`
do
  echo
  echo "Checking ETH link status for $i"
#  cat $BOND_DIR/$i | egrep "Bonding Mode|Active|Interface|MII Status|Speed"
  ETH_COUNT=`cat $BOND_DIR/$i | grep "Slave Interface: "| cut -d ":" -d ' ' -f3|wc -l`
  cat $BOND_DIR/$i | grep "Slave Interface: "| cut -d ":" -d ' ' -f3 > /tmp/ethnames
  if [[ $ETH_COUNT == 2 ]]
  then 
    echo "$i has 2 ETH links i.e (`cat /tmp/ethnames|tr '\n' ' '`) as expected."
  else
    echo "$i has 1 ETH link i.e (`cat /tmp/ethnames|tr '\n' ' '`). Please check the second ETH status."
  fi
  
  for j in `cat /tmp/ethnames`
  do
    cat $BOND_DIR/$i | grep -A1 "Slave Interface"|grep -A1 $j|egrep "up|down"| cut -d ":" -d ' ' -f3 > /tmp/ethstatus
    for k in `cat /tmp/ethstatus`
    do
      if [[ $k == down ]]
      then
        echo "$j link status showing $k in $i. Please check the link status."
      else
        echo "$j link status showing $k in $i."
      fi
     done
  done
  FIRST_ETH_STATUS=`cat $BOND_DIR/$i | grep -A1 "Slave Interface"|egrep "up|down"| cut -d ":" -d ' ' -f3|sed -n '1p'`
  SECOND_ETH_STATUS=`cat $BOND_DIR/$i | grep -A1 "Slave Interface"|egrep "up|down"| cut -d ":" -d ' ' -f3|sed -n '2p'`
  if [[ $FIRST_ETH_STATUS == down ]] && [[ $SECOND_ETH_STATUS == up ]] 
  then
    echo "One of the links showing down in bonding configuration. Please verify the link status."
  elif [[ $FIRST_ETH_STATUS == up ]] && [[ $SECOND_ETH_STATUS == down ]]
  then
    echo "One of the links showing down in bonding configuration. Please verify the link status."
  else
    echo "All active ETH links are showing up in bonding configuration"
  fi
  echo
done
###########################################################

