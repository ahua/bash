#!/usr/bin/env bash

apt-get install -y glance glance-api glance-client glance-common glance-registry python-glance

# change glance-api-paste.ini and glance-registry-paste.ini
sed -i 's/admin_tenant_name.\+/admin_tenant_name = ADMIN/g' /etc/glance/glance-api-paste.ini
sed -i 's/admin_user.\+/admin_user = admin/g'               /etc/glance/glance-api-paste.ini
sed -i 's/admin_password.\+/admin_password = ADMIN/g'       /etc/glance/glance-api-paste.ini

sed -i 's/admin_tenant_name.\+/admin_tenant_name = ADMIN/g' /etc/glance/glance-registry-paste.ini
sed -i 's/admin_user.\+/admin_user = admin/g'               /etc/glance/glance-registry-paste.ini
sed -i 's/admin_password.\+/admin_password = ADMIN/g'       /etc/glance/glance-registry-paste.ini

# change glance-api.conf and glance-registry.conf
sed -i 's/sql_connection.\+/sql_connection = mysql:\/\/glance:glance@10.2.101.97\/glance/g' /etc/glance/glance-registry.conf

cat <<EOF >> /etc/glance/glance-registry.conf
[paste_deploy]
flavor = keystone
EOF

cat <<EOF >> /etc/glance/glance-api.conf
[paste_deploy]
flavor = keystone
EOF

glance-manage version_control 0
glance-manage db_sync

service glance-api restart && service glance-registry restart

#export OS_TENANT_NAME=ADMIN
#export OS_USERNAME=admin
#export OS_PASSWORD=ADMIN
#export OS_AUTH_URL="http://localhost:5000/v2.0/"

glance -T ADMIN -N http://localhost:5000/v2.0/ -I admin -K ADMIN add name="Ubuntu_12.04_amd_64_bit" is_public=true container_format=ovf disk_format=qcow2 < precise-server-cloudimg-amd64-disk1.img
