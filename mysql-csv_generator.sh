#!/bin/bash

DAY=$(date | awk '{print $2,$3}')
LOGDATE=$(date +"%Y_%m_%d")
DBDATE=$(date +"%Y-%m-%d")
S3-BUCKET="Your_S3_Bucket"

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
mysql -u "user" "-p(password)" -h "host" -e "SELECT query,answer,platform,confidence_level FROM fedneo.chat_history_log WHERE query!= 'GOOGLE_ASSISTANT_WELCOME' AND created_at BETWEEN '$DBDATE 00:00:00' AND '$DBDATE 23:59:59';" > chat_log.tsv
sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" chat_log.tsv > log-$LOGDATE.csv
tar -czf log-$LOGDATE.tar.gz log-$LOGDATE.csv

#Copying to AWS S3
#########################
aws s3 cp php7.2-fpm-$LOGDATE.tar.gz s3://$S3-BUCKET/php-fpm/
aws s3 cp mongodb-$LOGDATE.tar.gz s3://$S3-BUCKET/mongodb/
aws s3 cp access-$LOGDATE.tar.gz s3://$S3-BUCKET/webserver-access_logs/
aws s3 cp error-$LOGDATE.tar.gz s3://$S3-BUCKET/webserver-Error_logs/
aws s3 cp chat_log-$LOGDATE.tar.gz s3://$S3-BUCKET/Chatlogs/

#Removing all files except the script
#######################################

ls -1| grep -v 'script.sh'  | xargs rm
