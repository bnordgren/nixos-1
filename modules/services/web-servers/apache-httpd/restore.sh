#!/bin/sh

if (( $# != 1 )) ; then 
  echo Usage: $0 filename
  echo where filename is a gzip archive
  exit 0 
fi 

db=%DATABASE%
db_user=%DB_USER%
db_pw=%DB_PW%
db_host=%DB_HOST%

mysql=%MYSQL%/bin/mysql
gzip=%GZIP%/bin/gzip

$mysql -h $db_host -u $db_user -p$db_pw -e "DROP DATABASE $db ; CREATE DATABASE $db;" $db
$gzip -d < $1 | $mysql -h $db_host -u $db_user -p$db_pw $db