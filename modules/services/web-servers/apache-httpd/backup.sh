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

mysqldump=%MYSQL%/bin/mysqldump
gzip=%GZIP%/bin/gzip

# backup the database
$mysqldump -u $db_user -p$db_pw -h $db_host $db | $gzip > $1

