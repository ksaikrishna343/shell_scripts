#!/bin/bash

# Define the bond interface name and the slave interfaces
bond_interface="bond0"
slave_interfaces=($1 $2)

# Install the bonding kernel module
sudo modprobe bonding

# Create the bonding configuration file
sudo bash -c "cat > /etc/sysconfig/network-scripts/ifcfg-$bond_interface << EOL
DEVICE=$bond_interface
TYPE=Bond
NAME=$bond_interface
BONDING_OPTS="mode=balance-rr miimon=100"
ONBOOT=yes
BOOTPROTO=dhcp
EOL"

# Create the slave interface configuration files
for slave in "${slave_interfaces[@]}"; do
  sudo bash -c "cat > /etc/sysconfig/network-scripts/ifcfg-$slave << EOL
DEVICE=$slave
NAME=$slave
TYPE=Ethernet
ONBOOT=yes
MASTER=$bond_interface
SLAVE=yes
BOOTPROTO=none
EOL"
done

# Restart the network service
sudo systemctl restart network
