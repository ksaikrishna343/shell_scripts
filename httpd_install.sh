#!/bin/bash

# installing httpd package 

yum install httpd -y > /dev/null
systemctl start httpd > /dev/null
systemctl status httpd 

echo "httpd installation completed"
