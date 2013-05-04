#!/usr/bin/env bash

source config.sh

apt-get install -y nova-api nova-cert nova-common nova-compute nova-compute-kvm nova-doc nova-network nova-objectstore nova-scheduler nova-volume nova-consoleauth novnc python-nova python-novaclient

sed -i "s/admin_tenant_name.\+/admin_tenant_name = ADMIN/g" /etc/nova/api-paste.ini
sed -i "s/admin_user.\+/admin_user = admin/g"               /etc/nova/api-paste.ini
sed -i "s/admin_password.\+/admin_password = ADMIN/g"       /etc/nova/api-paste.ini

cat > /etc/nova/nova.conf <<EOF
--public_interface=$public_nic
--flat_interface=$flat_nic
--fixed_range=$fixed_range 
--iscsi_ip_address=$iscsi_ip 
--glance_api_servers=$glance_ip:9292 
--volume_group=$volume_group 
--vncserver_proxyclient_address=$compute_ip 
--vncserver_listen=$compute_ip 
--novncproxy_base_url=http://$control_ip:6080/vnc_auto.html
--sql_connection=mysql://$nova_db_user:$nova_db_passwd@$mysql_ip/nova
--rabbit_password=$rabbit_passwd
--rabbit_userid=$rabbit_user
--rabbit_host=$rabbit_ip
--libvirt_type=$vm_type

--flat_network_bridge=br100
--dhcpbridge=/usr/bin/nova-dhcpbridge
--dhcpbridge_flagfile=/etc/nova/nova.conf
--flat_injected=false
--state_path=/var/lib/nova
--connection_type=libvirt
--image_service=nova.image.glance.GlanceImageService
--use_deprecated_auth=false
--service_down_time=60
--vnc_enabled=true
--rabbit_port=5672
--verbose=false
--logdir=/var/log/nova
--rabbit_virtual_host=/
--dhcp_domain=novalocal
--iscsi_helper=tgtadm
--lock_path=/var/lock/nova
--root_helper=sudo nova-rootwrap
--api_paste_config=/etc/nova/api-paste.ini
--force_dhcp_release=true
--multi_host=True
--send_arp_for_ha=True
--auth_strategy=keystone
--network_manager=nova.network.manager.FlatDHCPManager
EOF

cat > /etc/nova/nova-compute.conf <<EOF
--libvirt_type=$vm_type
EOF

for a in libvirt-bin nova-network nova-compute nova-cert nova-api nova-objectstore nova-scheduler nova-volume novnc nova-consoleauth; do service "$a" stop; done
nova-manage db sync
for a in libvirt-bin nova-network nova-compute nova-cert nova-api nova-objectstore nova-scheduler nova-volume novnc nova-consoleauth; do service "$a" start; done
nova-manage network create private --fixed_range_v4=$fixed_range --num_networks=1 --bridge=br100 

for a in libvirt-bin nova-network nova-compute nova-cert nova-api nova-objectstore nova-scheduler nova-volume novnc nova-consoleauth; do service "$a" start; done

