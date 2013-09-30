#!/usr/bin/env bash

MYSQL_PASSWORD=ubuntu

cat <<MYSQL_PRESEED | sudo debconf-set-selections
mysql-server-5.1 mysql-server/root_password password $MYSQL_PASSWORD
mysql-server-5.1 mysql-server/root_password_again password $MYSQL_PASSWORD
mysql-server-5.1 mysql-server/start_on_boot boolean true
MYSQL_PRESEED

apt-get install -y mysql-server python-mysqldb

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

service mysql restart;

mysql -uroot -pubuntu <<EOF

drop database if exists nova;
create database nova;
grant all privileges on nova.* to 'nova'@'%' identified by 'nova';

drop database if exists glance;
create database glance;
grant all privileges on glance.* to 'glance'@'%' identified by 'glance';

drop database if exists keystone;
create database keystone;
grant all privileges on keystone.* to 'keystone'@'%' identified by 'keystone';

flush privileges;
EOF

