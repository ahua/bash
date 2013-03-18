#!/usr/bin/env bash

#http://www.rabbitmq.com/install-debian.html

echo "deb http://www.rabbitmq.com/debian/ testing main" | sudo tee -a /etc/apt/sources.list
cd /var/tmp/
wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
sudo apt-key add rabbitmq-signing-key-public.asc
sudo apt-get update
sudo apt-get install rabbitmq-server


sudo rabbitmqctl add_vhost appchannel
sudo rabbitmqctl list_vhosts
sudo rabbitmqctl add_user appchannel P@55word
sudo rabbitmqctl list_users
sudo rabbitmqctl set_permissions -p appchannel appchannel ".*" ".*" ".*"
sudo rabbitmqctl list_permissions -p appchannel


