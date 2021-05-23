#!/bin/bash

#############################
# Script by zb.
# NB : I am not responsible if this undergone any issues...!!
##############################

user=$(echo $USER)
sts=$(systemctl is-active  nginx)

if [ $user == "root" ]; then

################
# Reading data from user
##########################

echo -n "Enter domain : "
read dom
Path=$(echo $dom | cut -d . -f 1)
echo -n "Enter Your IP address : "
read IP
echo -n "Enter your Port : "
read Port
mkdir -v /usr/share/nginx/$Path  &> /dev/null


###################
# Creating domain.conf for 
########################

cat <<EOF > /etc/nginx/sites-available/$Path.conf
server {

    root /usr/share/nginx/$Path;
    index index.php index.html index.htm;

    server_name $dom www.$dom;
    location / {
        try_files $uri $uri/ /index.php;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        include snippets/fastcgi-php.conf;
    }
}

server {
    listen 80;
    server_name $dom www.$dom;

    location / {
        proxy_pass http://$IP:$Port;
        #proxy_set_header Host $host;
        #proxy_set_header X-Real-IP $remote_addr;
        #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #proxy_set_header X-Forwarded-Proto $scheme;
    }
}

EOF

###########

ln -s /etc/nginx/sites-available/$Path.conf	/etc/nginx/sites-enabled/$Path.conf
echo -e "\n\n ****\n****\n\nConfiguration files created \n******"
echo -e "*****\n Reloading nginx \n**********"

################

systemctl reload nginx &> /dev/null

    if [ $sts == "active" ]; then
        echo -e "\n\nNginx has now reloaded \n Service status of nginx $sts \nPlease check all working now"
    else
        echo "Status of nginx is $sts Please check........"
    fi
###################

else
    echo "!!!!!!!!!! Run this script as root user"

fi

##################
# Script Completed
##########################
