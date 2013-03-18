#!/usr/bin/env bash

echo "deb http://www.rabbitmq.com/debian/ testing main" | sudo tee -a /etc/apt/sources.list
cd /var/tmp/
wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
sudo apt-key add rabbitmq-signing-key-public.asc
sudo apt-get update
sudo apt-get install rabbitmq-server
