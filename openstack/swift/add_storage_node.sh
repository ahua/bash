#!/usr/bin/env bash

source config.sh
source functions

apt-get update && apt-get upgrade -y
apt-get install -y python-software-properties swift python-swift openssh-server
apt-get install -y swift-account swift-container swift-object xfsprogs

mkdir -p /etc/swift
chown -R swift:swift /etc/swift/

my_ip=`get_my_ip`

lv_name=swiftnode
vg_name=`hostname`

if [ -L /dev/$vg_name/$lv_name ]; then
  umount /dev/$vg_name/$lv_name
  lvremove /dev/$vg_name/$lv_name
fi

lvcreate -L 10G -n $lv_name $vg_name
mkfs.xfs -i size=1024 /dev/$vg_name/$lv_name
echo "/dev/"$vg_name"/"$lv_name" /srv/node/sdb1 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0" >> /etc/fstab
mkdir -p /srv/node/sdb1
mount /srv/node/sdb1
chown -R swift:swift /srv/node

cat >/etc/rsyncd.conf <<EOF
uid = swift
gid = swift
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
address = $my_ip

[account]
max connections = 2
path = /srv/node/
read only = false
lock file = /var/lock/account.lock

[container]
max connections = 2
path = /srv/node/
read only = false
lock file = /var/lock/container.lock

[object]
max connections = 2
path = /srv/node/
read only = false
lock file = /var/lock/object.lock
EOF

perl -pi -e 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync
service rsync start

cat >/etc/swift/account-server.conf <<EOF
[DEFAULT]
bind_ip = $my_ip
workers = 2

[pipeline:main]
pipeline = account-server

[app:account-server]
use = egg:swift#account

[account-replicator]

[account-auditor]

[account-reaper]
EOF

cat >/etc/swift/container-server.conf <<EOF
[DEFAULT]
bind_ip = $my_ip
workers = 2

[pipeline:main]
pipeline = container-server

[app:container-server]
use = egg:swift#container

[container-replicator]

[container-updater]

[container-auditor]

[container-sync]
EOF

cat >/etc/swift/object-server.conf <<EOF
[DEFAULT]
bind_ip = $my_ip
workers = 2

[pipeline:main]
pipeline = object-server

[app:object-server]
use = egg:swift#object

[object-replicator]

[object-updater]

[object-auditor]
EOF

chmod 777 /etc/swift
scp ubuntu@$PROXY_IP:/etc/swift/swift.conf /etc/swift/
scp ubuntu@$PROXY_IP:/etc/swift/account.ring.gz /etc/swift/
scp ubuntu@$PROXY_IP:/etc/swift/container.ring.gz /etc/swift/
scp ubuntu@$PROXY_IP:/etc/swift/object.ring.gz /etc/swift/
chmod 755 /etc/swift
chown -R swift:swift /etc/swift

swift-init all start
