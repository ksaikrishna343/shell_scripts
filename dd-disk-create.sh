#!/bin/bash

#dd disk create

#dd if=/dev/zero of=/home/disk0.img bs=1 count=1024 seek=20M

for i in 0 1 2 3
do
  dd if=/dev/zero of=/home/disk$i.img bs=1 count=1024 seek=20M
  losetup -f /home/disk$i.img
done

