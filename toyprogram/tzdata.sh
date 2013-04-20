#!/usr/bin/env bash

echo "Asia/Shanghai" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata


