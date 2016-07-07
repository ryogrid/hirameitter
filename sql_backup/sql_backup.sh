#!/bin/sh

/usr/bin/find /home/ryo/rails_apps/hirameitter/sql_backup/ -name "*.sql" -mtime +10 -mindepth 1 -exec \rm -rf '{}' ';'
/usr/bin/mysqldump -u ryo hirameki --password=hogehoge > /home/ryo/rails_apps/hirameitter/sql_backup/back`date +%Y-%m-%d`.sql
