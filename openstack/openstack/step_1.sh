#!/usr/bin/env bash

apt-get install -y ntp 

cat <<EOF >> /etc/ntp.conf
server ntp.ubuntu.com iburst
server 127.127.1.0
fudge 127.127.1.0 stratum 10
EOF

service ntp restart

apt-get install -y tgt
service tgt start
apt-get install -y open-iscsi open-iscsi-utils
apt-get install -y bridge-utils
/etc/init.d/networking restart
apt-get install -y rabbitmq-server memcached python-memcache
apt-get install -y kvm libvirt-bin

