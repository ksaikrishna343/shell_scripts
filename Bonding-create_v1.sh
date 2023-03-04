#!/bin/bash

# bondit.sh -bond <bondname> -nic1 <first eth> -nic2 <second eth>

usage ()
{
  echo 'Usage : bondit.sh -bond <bondname> -nic1 <first eth> -nic2 <second eth>'
  exit
}

if [ "$#" -ne 6 ]
then
  usage
fi

while [ "$1" != "" ]; do
case $1 in
        -bond )        shift
                       BONDNAME=$1
                       ;;
        -nic1 )        shift
                       firstETH=$1
                       ;;
        -nic2 )        shift 
                       secondETH=$1
                       ;;
        * )            echo "Syntax Error"
                       usage
                       ;;
    esac
    shift
done

# extra validation suggested by @technosaurus
if [ "$BONDNAME" = "" ]
then
    usage
fi
if [ "$firstETH" = "" ]
then
    usage
fi
if [ "$secondETH" = "" ]
then
    usage
fi

echo;echo
echo Developed by Jed S. Walker - September 9th, 2011
echo version=20110912.b

echo
echo Warning!! If you have modified the original ifcfg files
echo this could cause issues. Be sure you have the original versions
echo hit enter to continue, or ctl-c to exit
read continue

export bond_val=$1
export eth1_val=$2
export eth2_val=$3

echo 
echo Backup files                      
cd /etc/modprobe.d
cp bonding.conf _bonding.conf.orig     
ls -l *bonding.conf*                   
cd /etc/sysconfig/network-scripts
cp "ifcfg-"$eth1_val "_ifcfg-"$eth1_val".orig"
cp "ifcfg-"$eth2_val "_ifcfg-"$eth2_val".orig"
ls -l *ifcfg*

echo If the backups look good then hit enter to continue or ctl-c to exit
read continue

echo 
echo Build ifcfg-$bond_val             
echo DEVICE=$bond_val                     > "ifcfg-"$bond_val
echo ONBOOT=yes                          >> "ifcfg-"$bond_val
echo BOOTPROTO=none                      >> "ifcfg-"$bond_val
echo USERCTL=no                          >> "ifcfg-"$bond_val
echo BONDING_OPTS=\"mode=1 miimon=100\"  >> "ifcfg-"$bond_val
grep IPADDR "_ifcfg-"$eth1_val".orig"    >> "ifcfg-"$bond_val
grep NETMASK "_ifcfg-"$eth1_val".orig"   >> "ifcfg-"$bond_val
grep GATEWAY "_ifcfg-"$eth1_val".orig"   >> "ifcfg-"$bond_val

echo
echo Add $bond_val to bonding.conf
echo "alias "$bond_val" bonding" >> /etc/modprobe.d/bonding.conf
echo now running "modprobe bonding..."
modprobe bonding

echo
echo Build ifcfg-$eth1_val
grep "^#" "_ifcfg-"$eth1_val".orig"     > "ifcfg-"$eth1_val
echo DEVICE=$eth1_val                  >> "ifcfg-"$eth1_val
echo USERCTL=no                        >> "ifcfg-"$eth1_val
echo ONBOOT=yes                        >> "ifcfg-"$eth1_val
echo BOOTPROTO=none                    >> "ifcfg-"$eth1_val
echo MASTER=$bond_val                  >> "ifcfg-"$eth1_val
echo SLAVE=yes                         >> "ifcfg-"$eth1_val
grep HWADDR "_ifcfg-"$eth1_val".orig"  >> "ifcfg-"$eth1_val

echo 
echo Build ifcfg-$eth2_val
grep "^#" "_ifcfg-"$eth2_val".orig"     > "ifcfg-"$eth2_val
echo DEVICE=$eth2_val                   > "ifcfg-"$eth2_val
echo USERCTL=no                        >> "ifcfg-"$eth2_val
echo ONBOOT=yes                        >> "ifcfg-"$eth2_val
echo BOOTPROTO=none                    >> "ifcfg-"$eth2_val
echo MASTER=$bond_val                  >> "ifcfg-"$eth2_val
echo SLAVE=yes                         >> "ifcfg-"$eth2_val
grep HWADDR "_ifcfg-"$eth2_val".orig"  >> "ifcfg-"$eth2_val

echo
echo Files by mod time
#cd /etc/
ls -lrt modprobe.d/bonding.*
#cd /etc/sysconfig/network-scripts
ls -lrt *ifcfg*

echo
echo Verify that the files above contain correct bond entries
echo The bond config file should have DEVICE=
echo The eth configs should have MASTER=
grep $bond_val ifcfg*

echo
echo Now running "service network restart"
echo If things lock up here you'll need to use iLO or console to reboot the server
service network restart
sleep 1
service network status

echo
echo When you have finished all bonding then run
echo ifconfig -a
echo It is then a good idea to reboot to make sure everything is clean

echo
echo Complete.
