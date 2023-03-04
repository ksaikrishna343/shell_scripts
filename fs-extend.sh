#!/bin/bash

# This script is used to extend the file system size in LVM

usage ()
{
cat << EOF
usage : $0 -lv <lvname> -disk <diskname>

 OPTIONS:
   -lv   :  lvname
   -disk :  diskname

EOF
  exit
}

if [ "$#" -ne 4 ]
then
  usage
fi

while [ "$1" != "" ]; do
case $1 in
        -lv )          shift
                       lvname=$1
                       ;;
        -disk )        shift
                       diskname=$1
                       ;;
        * )            echo "Syntax Error"
                       usage
                       ;;
    esac
    shift
done

# extra validation
if [ "$lvname" = "" ]
then
    usage
fi
if [ "$diskname" = "" ]
then
    usage
fi


export LVNAME=$lvname
export DISKNAME=$diskname

/sbin/lvs | grep -w $LVNAME  &> /dev/null
if [[ $? == 0 ]]
then
  VGNAME=`/sbin/lvs | grep -w $LVNAME|awk '{print $2}'`
  echo "LV $LVNAME belongs to $VGNAME VG"
else
  echo "LV $LVNAME not found. Exiting..!"
  exit 1
fi

/sbin/losetup -a| grep -w $DISKNAME &> /dev/null
if [[ $? == 0 ]]
then
  echo "Disk $DISKNAME is found.."
else
  echo "Disk $DISKNAME not found. Exiting..!"
  exit 1
fi

PVCHECK=`/sbin/pvs | grep -w $DISKNAME|awk '{print $2}'`
if [[ $PVCHECK =~ "lvm" ]]
then
  echo "$DISKNAME is free. Hence proceeding"
else
  echo "$DISKNAME is already used in $PVCHECK VG. Exiting..!"
  exit 1
fi

/bin/df -h |grep -w $LVNAME  &> /dev/null
if [[ $? == 0 ]]
then
  MOUNT=`/bin/df -h |grep -w $LVNAME|awk '{print $6}'`
  echo "$LVNAME is mounted on $MOUNT mount point"
else
  echo "$LVNAME is not mounted. Exiting..!"
  exit 1
fi


#VGNAME=`/sbin/lvs | grep -w $1|awk '{print $2}'`
#VGNAME=`/sbin/lvs | grep  "\testlv\b"|awk '{print $2}'`

#LVNAME=$1
#DISKNAME=$2
PVNAME=/dev/$DISKNAME
FS=/dev/$VGNAME/$LVNAME
echo
echo "Proceeding with FS extension"
pvcreate $PVNAME
vgextend $VGNAME $PVNAME
lvextend -l +100%FREE $FS /dev/$DISKNAME
echo

FSTYPE=`df -hT |grep -w $LVNAME|awk '{print $2}'`
echo "FS type is $FSTYPE"

if [[ $FSTYPE == ext4 ]]
then
  resize2fs $FS
elif [[ $FSTYPE == xfs ]]
then
  xfs_growfs $FS
else
  echo "FS is not mounted. Please check."
fi

