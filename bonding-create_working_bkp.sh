#!/bin/bash

# bonding-create.sh -bond <bondname> -nic1 <first eth> -nic2 <second eth>

# This script is used to create bonding for RedHat 6 and CentOS 6 and above versions

usage ()
{
cat << EOF
usage : $0 -bond <bondname> -nic1 <first eth name> -nic2 <second eth name>'

 OPTIONS:
   -bond :  bondname
   -nic1 :  first eth name
   -nic2 :  second eth name

EOF
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

# extra validation 
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
echo Developed by Sai Krishna - September 9th, 2022
echo version=20220909.b

echo
echo Warning!! If you have modified the original ifcfg files
echo this could cause issues. Be sure you have the original versions
echo hit enter to continue, or ctl-c to exit
read continue

echo
OS_CHECK=`cat /etc/os-release |grep ^NAME|cut -d "=" -f2`

if [[ $OS_CHECK =~ "CentOS" ]] || [[ $OS_CHECK =~ "Red Hat" ]]
then
  echo "OS check passed. This is $OS_CHECK server. Hence proceeding with next steps.."
else
  echo "OS check failed. This is $OS_CHECK server. This script is for CentOS/RedHat servers. Hence aborting the script.."
  exit 1
fi

echo
# exporting bond and eth variables. These are coming above case statement
export bond_val=$BONDNAME
export eth1_val=$firstETH
export eth2_val=$secondETH

# ifcfg-eth* file check whether given ETH names in command are exists or not in network-script directory
cd /etc/sysconfig/network-scripts
#eth_count_check=`ls -lrt |egrep "$eth1_val|$eth2_val" | wc -l`
ifcfg_file_count_check=`ls -lrt |egrep "$eth1_val|$eth2_val" | awk '{print $9}' | cut -d "_" -d "-" -d "." -f1 | awk -F '[ifcfg][-]' '{print $2}' |sort | uniq |wc -l`

if [[ $ifcfg_file_count_check -lt 2 ]]
then
  echo "Please check ETH names mentioned in command line. Seems to be one of them doesn't exist"
  exit 1
fi 

echo
 
# Taking network configuration files backup 
cd /etc/modprobe.d
cat /etc/modprobe.d/bonding.conf | grep $BONDNAME  &> /dev/null
if [[ $? == 0 ]]
then
  echo "$BONDNAME in bonding.conf file already exists. Seems to be bonding configuration already done..!"
  echo "Checking bonding configuration status"
#  cat /proc/net/bonding/bond0
  echo
  echo "Bonding Name: $BONDNAME"
  cat /proc/net/bonding/$BONDNAME |egrep "Bonding Mode|Active|Interface|MII Status|Speed"
  exit 1
fi

cp bonding.conf _bonding.conf.orig &> /dev/null    
ls -l *bonding.conf*               &> /dev/null    
echo

cd /etc/sysconfig/network-scripts
bonding_check=`cat ifcfg-"$eth1_val" ifcfg-"$eth2_val" | grep bond |wc -l`
bonding_name=`cat ifcfg-enp0s9 | grep bond | cut -d "=" -f2`
if [[ $bonding_check -eq 2 ]]
then
  echo "$bonding_name in ifcfg-"$eth1_val" and ifcfg-"$eth2_val" files is already exists. Seems to be bonding configuration already done..!"
  echo "Checking bonding configuration status"
#  cat /proc/net/bonding/bond0
  echo
  echo "Bonding Name: $bonding_name"
  cat /proc/net/bonding/$bonding_name |egrep "Bonding Mode|Active|Interface|MII Status|Speed"
  exit 1
fi

cp "ifcfg-"$eth1_val "_ifcfg-"$eth1_val".orig"
cp "ifcfg-"$eth2_val "_ifcfg-"$eth2_val".orig"
ls -lrt *ifcfg-$eth1_val* *ifcfg-$eth2_val*

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
echo Adding $bond_val to bonding.conf
echo "alias "$bond_val" bonding" >> /etc/modprobe.d/bonding.conf
echo Now running "modprobe bonding..."
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
echo DEVICE=$eth2_val                  >> "ifcfg-"$eth2_val
echo USERCTL=no                        >> "ifcfg-"$eth2_val
echo ONBOOT=yes                        >> "ifcfg-"$eth2_val
echo BOOTPROTO=none                    >> "ifcfg-"$eth2_val
echo MASTER=$bond_val                  >> "ifcfg-"$eth2_val
echo SLAVE=yes                         >> "ifcfg-"$eth2_val
grep HWADDR "_ifcfg-"$eth2_val".orig"  >> "ifcfg-"$eth2_val

echo
echo Files by mod time
cd /etc/modprobe.d
ls -lrt *bonding.*

echo
echo Verify that the files above contain correct bond entries
echo The bond config file should have DEVICE=
echo The eth configs should have MASTER=
cd /etc/sysconfig/network-scripts
grep $bond_val ifcfg*

echo
echo Now running "service network restart"
echo If things lock up here you will need to use iLO or console to reboot the server
#systemctl restart network
service network restart
sleep 5
#systemctl status network 
service network status

echo
echo When you have finished all bonding then run
echo ifconfig $bond_val
ifconfig $bond_val
echo It is then a good idea to reboot to make sure everything is clean

echo
echo "Bonding configuration has been completed."
echo "Below is bonding configuration status"
echo
echo "Bonding Name: $BONDNAME"
cat /proc/net/bonding/$BONDNAME |egrep "Bonding Mode|Active|Interface|MII Status|Speed"
echo

