#!/usr/bin/env bash

source config.sh

apt-get install -y glance glance-api glance-client glance-common glance-registry python-glance

# change glance-api-paste.ini and glance-registry-paste.ini
sed -i 's/admin_tenant_name.\+/admin_tenant_name = ADMIN/g' /etc/glance/glance-api-paste.ini
sed -i 's/admin_user.\+/admin_user = admin/g'               /etc/glance/glance-api-paste.ini
sed -i 's/admin_password.\+/admin_password = ADMIN/g'       /etc/glance/glance-api-paste.ini

sed -i 's/admin_tenant_name.\+/admin_tenant_name = ADMIN/g' /etc/glance/glance-registry-paste.ini
sed -i 's/admin_user.\+/admin_user = admin/g'               /etc/glance/glance-registry-paste.ini
sed -i 's/admin_password.\+/admin_password = ADMIN/g'       /etc/glance/glance-registry-paste.ini

# change glance-api.conf and glance-registry.conf
sed -i "s/sql_connection.\+/sql_connection = mysql:\/\/$glance_db_user:$glance_db_passwd@$mysql_ip\/glance/g" /etc/glance/glance-registry.conf

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

