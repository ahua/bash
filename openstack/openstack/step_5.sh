#!/usr/bin/env bash

apt-get install -y nova-api nova-cert nova-common nova-compute nova-compute-kvm nova-doc nova-network nova-objectstore nova-scheduler nova-volume nova-consoleauth novnc python-nova python-novaclient

# change /etc/nova/nova.conf
# change /etc/nova/api-paste.ini

# change /usr/lib/python2.7/dist-packages/nova/volume/driver.py

nova-manage db sync

nova-manage network create private --fixed_range_v4=192.168.22.129/25 --num_networks=1 --bridge=br100 --bridge_interface=eth0 --network_size=128

#lvreduce -L -400G /dev/os-control/root # this is wrong 

for a in libvirt-bin nova-network nova-compute nova-cert nova-api nova-objectstore nova-scheduler nova-volume novnc nova-consoleauth; do service "$a" stop; done
for a in libvirt-bin nova-network nova-compute nova-cert nova-api nova-objectstore nova-scheduler nova-volume novnc nova-consoleauth; do service "$a" start; done


