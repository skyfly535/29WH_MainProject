#!/bin/bash

RESULT_FILE="test.txt"

docker-compose exec database mysql -uroot -pPassw0rd! \
  -e "SHOW VARIABLES WHERE Variable_name = 'hostname';" \
  -e "SELECT * FROM performance_schema.replication_group_members;" > $RESULT_FILE

CODE=$(egrep -c 'ONLINE' $RESULT_FILE)

cat $RESULT_FILE
rm $RESULT_FILE

if [[ $CODE == 3 ]]; then
    echo "Test check passed, 3 nodes ONLINE"
    exit 0
else
    echo "Test check failed"
    exit 1
fi
