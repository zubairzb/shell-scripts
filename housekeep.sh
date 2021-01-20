#!/bin/bash

#############################
# NB : I am not responsible if this undergone any issues...!!
##############################


now=$(date +"%m_%d_%Y")

##############
# getting the values
##############

echo -n "Enter account name : "
read ac

echo -e "\n\n#############" >> /usr/local/apache/htdocs/housekeeping_$now.txt
echo -e "# Checking cPanel accounting log" >> /usr/local/apache/htdocs/housekeeping_$now.txt
echo -e "#############" >> /usr/local/apache/htdocs/housekeeping_$now.txt

grep  $ac /var/cpanel/accounting.log >> /usr/local/apache/htdocs/housekeeping_$now.txt
hk=$(grep $ac /var/cpanel/accounting.log | grep -i create | awk '{print $5}' | cut -d : -f 5)

echo -e "\n\n\ndomain is $hk" >> /usr/local/apache/htdocs/housekeeping_$now.txt

##############
#Ping test
################

echo -e "\n\n#################" >> /usr/local/apache/htdocs/housekeeping_$now.txt
echo -e "#Doing Ping test" >> /usr/local/apache/htdocs/housekeeping_$now.txt
echo -e "#################" >> /usr/local/apache/htdocs/housekeeping_$now.txt

ping -c 3 $hk >> /usr/local/apache/htdocs/housekeeping_$now.txt

echo -e "\nPlease review the results on http://$HOSTNAME/housekeeping_$now.txt"


#####################
# Housekeeping
####################

echo -e "\n\n Press y if you want to remove the account now"
read op

if [ $op == "y" ]; then

echo -e "\n\n#################"
echo -e "HouseKeeping Started"
echo -e "##################"

/scripts/removeacct --keepdns --force $ac 1> /dev/null

echo -e "\n\n yo...yo....!!!!\nHousekeeping completed...................."
grep $ac /var/cpanel/accounting.log

else
    echo "Housekeeping Quiting!!!!"
fi

rm -f /usr/local/apache/htdocs/housekeeping_$now.txt


