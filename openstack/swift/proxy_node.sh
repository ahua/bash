#!/usr/bin/env bash

source functions

my_ip=`get_my_ip`
sed -i "s/PROXY_IP.\+/PROXY_IP=$my_ip/g" config.sh

source config.sh

apt-get update && apt-get upgrade -y
apt-get install -y python-software-properties
apt-get install -y swift python-swift openssh-server
mkdir -p /etc/swift
chown -R swift:swift /etc/swift/

cat >/etc/swift/swift.conf <<EOF
[swift-hash]
swift_hash_path_suffix=`od -t x8 -N 8 -A n </dev/random`
EOF

apt-get install -y swift-proxy memcached

cd /etc/swift; 
openssl req -new -x509 -nodes -out cert.crt -keyout cert.key

perl -pi -e "s/-l 127.0.0.1/-l $PROXY_IP/" /etc/memcached.conf
service memcached restart

cat >/etc/swift/proxy-server.conf <<EOF
[DEFAULT]
cert_file = /etc/swift/cert.crt
key_file = /etc/swift/cert.key
bind_port = 8080
workers = 8
user = swift

[pipeline:main]
pipeline = healthcheck cache tempauth proxy-server

[app:proxy-server]
use = egg:swift#proxy
allow_account_management = true
account_autocreate = true

[filter:tempauth]
use = egg:swift#tempauth
user_system_root = testpass .admin https://$PROXY_IP:8080/v1/AUTH_system

[filter:healthcheck]
use = egg:swift#healthcheck

[filter:cache]
use = egg:swift#memcache
memcache_servers = $PROXY_IP:11211
EOF

function add_entry_for_ring()
{
    ZONE=$1
    STORAGE_IP=$2
    WEIGHT=100
    DEVICE=sdb1
    swift-ring-builder account.builder add   z$ZONE-$STORAGE_IP:6002/$DEVICE $WEIGHT
    swift-ring-builder container.builder add z$ZONE-$STORAGE_IP:6001/$DEVICE $WEIGHT
    swift-ring-builder object.builder add    z$ZONE-$STORAGE_IP:6000/$DEVICE $WEIGHT
}

cd /etc/swift
swift-ring-builder account.builder create 18 3 1
swift-ring-builder container.builder create 18 3 1
swift-ring-builder object.builder create 18 3 1

zone_id=1
for storage_ip in ${STORAGE_IPS[@]}; do 
    add_entry_for_ring $zone_id $storage_ip
    zone_id=$(($zone_id+1))
done

swift-ring-builder account.builder rebalance
swift-ring-builder container.builder rebalance
swift-ring-builder object.builder rebalance

chown -R swift:swift /etc/swift/
swift-init proxy start

