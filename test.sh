#!/bin/bash

# Define the bond interface name and the slave interfaces
bond_interface="bond0"
slave_interfaces=(eth0 eth1)

# Install the bonding kernel module
sudo modprobe bonding

# Configure the bonding interface
sudo bash -c "cat > /etc/network/interfaces << EOL
# Bonding interface
auto $bond_interface
iface $bond_interface inet dhcp
    bond-mode 0
    bond-slaves none
EOL"

# Configure the slave interfaces
for slave in "${slave_interfaces[@]}"; do
  sudo bash -c "cat >> /etc/network/interfaces << EOL
# $slave interface
auto $slave
iface $slave inet manual
    bond-master $bond_interface
EOL"
done

## Restart the network service
sudo systemctl restart networking
