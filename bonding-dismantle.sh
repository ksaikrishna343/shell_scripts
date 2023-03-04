#!/bin/bash
cd /etc/sysconfig/network-scripts
yes | cp -p _ifcfg-enp0s9.orig ifcfg-enp0s9
yes | cp -p _ifcfg-enp0s10.orig ifcfg-enp0s10
rm -rf _ifcfg-enp0s9.orig  _ifcfg-enp0s10.orig ifcfg-bond0
rm -rf /etc/modprobe.d/*bonding.conf*
service network restart
service network status
