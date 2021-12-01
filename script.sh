#!/bin/bash

DAY=$(date | awk '{print $2,$3}')
LOGDATE=$(date +"%Y_%m_%d")
DBDATE=$(date +"%Y-%m-%d")

###########################################
# Moving to S3 directory in local host
##########################################
cd /usr/local/src/s3/

######################################
#Copying log files to S3 local
#####################################
for i in `ls -l /var/log/ | grep php | grep "$DAY" | awk '{print $9}'`;
do
cp -apf $i . ;
done

for i in `ls -l /var/log/mongodb/ | grep "$DAY" | awk '{print $9}'`;
do
cp -apf $i . ;
done

for i in `ls -l /var/log/nginx/ | grep "$DAY" | awk '{print $9}'`;
do
cp -apf $i . ;
done

######################################
# Renaming all the files
######################################
for file in *.log;
do
        ext="${file##*.}";
        filename="${file%.*}";
        mv "$file" "${filename}-$LOGDATE.${ext}";
done

#Compressing the logs
#############################

for item in *.log;
do
    itemname="${item%.*}";
    tar -czf ${itemname}-$LOGDATE.tar.gz $item;
done

# Generating Chatlog
##############################
mysql -u "riafy_master" "-pFFEJ7Mshcb4zHH9hRp_u" -h production-rds.cdgjiicnmnry.ap-south-1.rds.amazonaws.com -e "SELECT query,answer,platform,confidence_level FROM fedneo.chat_history_log WHERE query!= 'GOOGLE_ASSISTANT_WELCOME' AND created_at BETWEEN '$DBDATE 00:00:00' AND '$DBDATE 23:59:59';" > chat_log.tsv
sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" chat_log.tsv > chat_log-$LOGDATE.csv
tar -czf chat_log-$LOGDATE.tar.gz chat_log-$LOGDATE.csv

#Copying to AWS S3
#########################
aws s3 cp php7.2-fpm-$LOGDATE.tar.gz s3://fedneo-logs/php-fpm/
aws s3 cp mongodb-$LOGDATE.tar.gz s3://fedneo-logs/mongodb/
aws s3 cp access-$LOGDATE.tar.gz s3://fedneo-logs/webserver-access_logs/
aws s3 cp error-$LOGDATE.tar.gz s3://fedneo-logs/webserver-Error_logs/
aws s3 cp chat_log-$LOGDATE.tar.gz s3://fedneo-logs/Chatlogs/

#Removing all files except the script
#######################################

ls -1| grep -v 'script.sh'  | xargs rm
