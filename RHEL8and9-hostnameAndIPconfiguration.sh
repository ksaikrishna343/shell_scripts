#!/bin/bash
#script to configure the network settings on this server
echo "CAUTION..! Make sure you are selected correct VLAN in network settings for VM."
read -p "Do you want to proceed? (yes/no) " yn

case $yn in
        yes ) echo Proceeding with the configuration...;;
        no ) echo exiting...;
                exit;;
        * ) echo invalid response;
                exit 1;;
esac

read -p "Enter hostname of the server: " servername
read -p "Enter IP Address of the server: " ipaddress
read -p "Enter subnetmask of IP ex.8/16/24: " subnetmask
read -p "Enter gateway IP of the server: " gateway
read -p "Enter dns server IP: " dnsserver

hostnamectl set-hostname $servername
nmcli connection add con-name ens192 ifname ens192 type ethernet > /dev/null 2>&1
nmcli connection modify ens192 ipv4.method manual ipv4.address $ipaddress/$subnetmask ipv4.gateway $gateway ipv4.dns $dnsserver ipv4.dns-search sdxcorp.io
sleep 5
nmcli connection modify ens192 ipv6.method "disabled"
echo "Network configuration is in progress..."
sleep 60
echo " "
echo "Network connection status"
nmcli connection show
sleep 5
echo " "
#gateway ping test
if ping -c 2 $gateway > /dev/null 2>&1; then
  echo "Ping to gateway IP was successful. Network configuration looks to be fine."
else
  echo "Ping to gateway IP is failed. Seems to be server not in network. Check the network settings..."
  exit 1
fi
echo "hostname and IP address has been set for the server."
sleep 5
echo "satellite subscription is in progress..."
subscription-manager register --serverurl=10.32.150.27 --username subsuser --password rbW*a744NfcwYJYIxpuG > /dev/null 2>&1
echo "satellite subscription has been completed."
sleep 5
echo " "
cp /etc/motd.orig /etc/motd
cp /etc/profile.d/login-info.sh.orig /etc/profile.d/login-info.sh
echo "rebooting the server in 10 seconds..."
sleep 10
init 6
