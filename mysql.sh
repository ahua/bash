#!/usr/bin/env bash

mysqldump -uroot -pPASSWD -h host database > backup.sql
mysql -uroot -pPASSWD database < backup.sql

