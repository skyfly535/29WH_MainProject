#!/bin/bash
fdate=`date +"%Y-%m-%d_%H-%M"`
path=/home/vagrant/project/dump
cd /home/vagrant/project
# echo "Cоздание потабличног бекапа всех баз данных сервера (кроме служебные базы)"
for dbname in `echo show databases | docker-compose exec -T node2 mysql -uroot -pPassw0rd! | grep -v Database`;
do
    case $dbname in
      information_schema)
      continue ;;
      mysql)
      continue ;;
      performance_schema)
      continue ;;
      sys)
      continue ;;
     *) for tablename in `echo show tables from $dbname | docker-compose exec -T node2 mysql -uroot -pPassw0rd! | grep -v Table`;
           do
              mkdir -p $path/$fdate/$dbname  
              docker-compose exec node2 /usr/bin/mysqldump -u root --password=Passw0rd! $dbname $tablename > $path/$fdate/$dbname/$tablename.sql
              gzip $path/$fdate/$dbname/$tablename.sql
              # echo  "Бекап таблицы" $tablename "из базы данных" $dbname "создан"
            done
        esac
done;
# Удаляем файлы старше 10-ти дней
/usr/bin/find "$path" -type f -mtime +10 -exec rm -rf {} \;
exit 0
