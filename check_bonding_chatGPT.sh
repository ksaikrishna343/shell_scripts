#!/bin/bash

# Check if the bonding module is loaded
if lsmod | grep -q bonding; then
  echo "Bonding module is loaded."
else
  echo "Bonding module is not loaded."
  exit 1
fi

# Get the bonding interface status
bonding_interface=$(ls /proc/net/bonding/)

# Check if the bonding interface exists
if [ -z "$bonding_interface" ]; then
  echo "No bonding interface found."
  exit 1
else
  echo "Bonding interface found: $bonding_interface"
fi

# Check the status of each slave in the bonding interface
for slave in $(cat /proc/net/bonding/$bonding_interface | grep "Slave Interface: "| cut -d ":" -d ' ' -f3); do
  echo "Checking slave interface: $slave"
  if cat /sys/class/net/$slave/operstate | grep -q up; then
    echo "$slave is up."
  else
    echo "$slave is down."
  fi
done

if [[ $slave == up ]] && [[ $slave == up ]]
then
  echo "Bonding configuration looks good"
else
  echo "One of the links in $bonding_interface configuration showing down. Please check link status"
fi
