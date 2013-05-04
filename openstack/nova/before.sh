#!/usr/bin/env bash

source config.sh

echo $hostname > /etc/hostname
sed -i "s/`hostname`/$hostname/g" /etc/hosts
hostname -F /etc/hostname

cat > /etc/network/interfaces <<EOF
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto $public_nic
iface $public_nic inet static
        address $ip
        netmask $netmask
        network $network
        broadcast $broadcast
        gateway $gateway
        dns-nameservers $dns_server
        dns-search $dns_search

auto $flat_nic
iface $flat_nic inet manual
    up ifconfig $flat_nic up
EOF

