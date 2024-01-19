#!/bin/bash
#script to configure the network settings on this server
echo "CAUTION..! Before proceeding, please make sure you have selected correct VLAN in network settings for VM."
read -p "Do you want to proceed? (yes/no): " yn
case $yn in
        yes ) echo Proceeding with the configuration...;;
        no ) echo Exiting...;
                exit;;
        * ) echo Invalid response;
                exit 1;;
esac
echo " "
read -p "Enter Hostname of the server: " SERVERNAME
read -p "Enter IP Address of the server: " IPADDRESS
read -p "Enter Subnet Mask of IP ex.8/16/24: " SUBNETMASK
read -p "Enter Gateway IP of the server: " GATEWAY
read -p "Enter DNS server IP: " DNSSERVER
#read -p "If above values are correct press enter to continue. Else press Ctrl+C to exit and re-run the script."

read -p "Are above given values correct? (yes/no): " YN
case $YN in
        yes ) echo Proceeding with next steps...;;
        no ) echo Exiting. Re-run the script with correct values.;
                exit;;
        * ) echo Invalid response;
                exit 1;;
esac
echo " "
echo "Network configuration is in progress..."
hostnamectl set-hostname $SERVERNAME
nmcli connection add con-name ens192 ifname ens192 type ethernet > /dev/null 2>&1
nmcli connection modify ens192 ipv4.method manual ipv4.address $IPADDRESS/$SUBNETMASK ipv4.gateway $GATEWAY ipv4.dns $DNSSERVER ipv4.dns-search sdxcorp.io
sleep 5
nmcli connection modify ens192 ipv6.method "disabled"
sleep 60
echo " "
echo "Network connection status"
nmcli connection show
sleep 5
echo " "
echo "Network configuration has been completed."
echo " "
#gateway ping test
echo "Pinging to gateway IP..."
if ping -c 2 $GATEWAY > /dev/null 2>&1; then
  echo "Ping to gateway IP was successful. Network configuration looks to be fine."
else
  echo "Ping to gateway IP has failed. Seems to be server not in the network. Check the network settings for VM and re-run the script..."
  nmcli connection delete ens192  > /dev/null 2>&1
  exit 1
fi
echo " "
echo "hostname and IP address has been set for the server."
sleep 5
echo " "
echo "satellite subscription is in progress..."
subscription-manager register --serverurl=10.32.150.27 --username subsuser --password rbW*a744NfcwYJYIxpuG > /dev/null 2>&1
echo "satellite subscription has been completed."
sleep 5
echo " "
cp /etc/motd.orig /etc/motd
cp /etc/profile.d/login-info.sh.orig /etc/profile.d/login-info.sh
echo "rebooting the server in 10 seconds...If you do not want to restart the server press Ctrl+C..."
sleep 12
init 6
