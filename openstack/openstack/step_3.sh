#!/usr/bin/env bash

apt-get install -y keystone python-keystone python-mysqldb python-keystoneclient

# replace [sql] connection in /etc/keystone/keystone.conf
sed -i 's/connection.\+/connection = mysql:\/\/keystone:keystone@10.2.101.97\/keystone/g' /etc/keystone/keystone.conf

service keystone restart
keystone-manage db_sync

wget http://www.hastexo.com/system/files/user/4/keystone_data.sh__0.txt -O /tmp/keystone_data.sh

sed -i 's/ADMIN_PASSWORD=.\+/ADMIN_PASSWORD=${ADMIN_PASSWORD:-ADMIN}/g' /tmp/keystone_data.sh
sed -i 's/export SERVICE_TOKEN=.\+/export SERVICE_TOKEN=ADMIN/g'        /tmp/keystone_data.sh
#sed -i 's/SERVICE_TENANT_NAME=.\+/SERVICE_TENANT_NAME=${SERVICE_TENANT_NAME:-service}/g' /tmp/keystone_data.sh

chmod u+x /tmp/keystone_data.sh && /tmp/keystone_data.sh

wget http://www.hastexo.com/system/files/user/4/endpoints.sh__0.txt -O /tmp/endpoints.sh
chmod u+x /tmp/endpoints.sh
/tmp/endpoints.sh -m 10.2.101.97 -u keystone -D keystone -p keystone -K 10.2.101.97 -R RegionOne -E "http://localhost:35357/v2.0" -S 10.2.101.97 -T ADMIN
