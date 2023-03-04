#!/bin/bash
##################################### Enter Threshold Values ########################################

ramthreshold=90

####################################### RAM Utilization #############################################

MemFree=`cat /proc/meminfo | grep MemFree | awk '{print $2}'`
Buffers=`cat /proc/meminfo| grep -i Buffers | awk '{print $2}'`
Cached=`cat /proc/meminfo| grep -i Cached|grep -v SwapCached| awk '{print $2}'`
MemTotal=`cat /proc/meminfo | grep -i MemTotal | awk '{print $2}'`
#ramperutil=`echo "scale = 4; ( $MemTotal - $MemFree - $Buffers - $Cached ) /  $MemTotal * 100 " | bc -l`
ramperutil=`echo "scale = 4; ( $MemTotal - $MemFree - $Buffers - $Cached ) /  $MemTotal * 100 " | bc -l`
#echo $ramperutil
python - $ramperutil $ramthreshold<<EOF

if ($ramperutil >= $ramthreshold):
        print $ramperutil
else:
        print $ramperutil
EOF

#if [[ $ramperutil -ge $ramthreshold ]]
#then
#  echo $ramperutil
#else
#  echo $ramperutil
#fi
