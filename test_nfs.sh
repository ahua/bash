#!/usr/bin/env bash

mkdir /primarymount
mount -t nfs 172.16.8.203:/export/primary /primarymount
touch /primarymount/testfile
umount /primarymount
mkdir /secondarymount
mount -t nfs 172.16.8.203:/export/secondary /secondarymount
touch /secondarymount/testfile
umount /secondarymount

