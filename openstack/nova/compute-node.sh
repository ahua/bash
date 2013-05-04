#!/usr/bin/env bash

source config.sh

apt-get install -y nova-compute nova-network nova-volume nova-api python-keystoneclient \
    python-keystone

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

service nova-compute restart
service nova-network restart
service nova-volume  restart
service nova-api     restart


