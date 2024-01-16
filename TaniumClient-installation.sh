#!/bin/bash
#Script to install tanium client on newly created linux server

#Ping test to satellite server IP to check whether server is in network or not
IP="10.32.150.27"

if ping -c 2 $IP > /dev/null 2>&1; then
  echo "Ping to Satellite server was successful. Proceeding with next steps..."
else
  echo "Ping to Satellite server failed. Seems to be server not in network. Check the network settings"
  exit 1
fi

#Installing tanium client
DIR=/var/tmp/agents/taniumclient-linux-bundle
cd $DIR && ./install.sh
if [ $? -eq 0 ]; then
  echo "tanium client installation was successful"
else
  echo "tanium client installation was failed. Please check manually"
  exit 1
fi

#Configuration settings
mkdir /opt/Tanium/TaniumClient/Tools
echo -e "PLX.Belux\nPLX.Europe" > /opt/Tanium/TaniumClient/Tools/CustomTags.txt
systemctl restart taniumclient
