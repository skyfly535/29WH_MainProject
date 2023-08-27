#!/bin/bash
docker stop wordpress
sleep 30
docker-compose exec database mysql -uroot -pPassw0rd! \
  -e "CREATE USER 'wpuser'@'%' IDENTIFIED BY 'Passw0rd!';" \
  -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%' WITH GRANT OPTION;" \
  -e "SET @@GLOBAL.group_replication_bootstrap_group=1;" \
  -e "create user 'repl'@'%';" \
  -e "GRANT REPLICATION SLAVE ON *.* TO repl@'%';" \
  -e "flush privileges;" \
  -e "change master to master_user='root' for channel 'group_replication_recovery';" \
  -e "START GROUP_REPLICATION;" \
  -e "SET @@GLOBAL.group_replication_bootstrap_group=0;" \
  -e "SELECT * FROM performance_schema.replication_group_members;"


for N in 2 3
do docker-compose exec node$N mysql -uroot -pPassw0rd! \
  -e "change master to master_user='repl' for channel 'group_replication_recovery';" \
  -e "START GROUP_REPLICATION;"
done
docker start wordpress