#!/bin/bash
sudo systemctl stop httpd
sudo yum remove httpd -y > /dev/null
echo "httpd uninstall completed"
