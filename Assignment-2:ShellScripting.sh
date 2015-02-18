#!/bin/bash
#defining TEMP
TEMP="`mktemp`"
#Defining echo function
#defining white color for Success.
function ee_info()
{
	echo $(tput setaf 7)$@$(tput sgr0)
}

#defining blue color for Running.
function ee_echo()
{
	echo $(tput setaf 4)$@$(tput sgr0)
}

#Defining red color for Error
function ee_fail()
{
	echo $(tput setaf 1)$@$(tput sgr0)
}
clear
ee_echo "Assignment Parts begins"

#Checking User Authentication
	if [[ $EUID -eq 0 ]]; then
		ee_info "Thank you for giving me a SUDO user recognition"
	else
		ee_fail "I need a SUDO privilage !! :( "
		ee_fail "Can i have your root password, before starting with me. For eg. sudo Assignment"
	exit 1
	fi

ee_info "Woo !! You have passed the Authentication part. Congratulation"
#Updating Ubuntu
ee_echo "Let me Update your System. Please wait..."
		apt-get update &>> /dev/null
ee_info "Woo !!Finally i have updated your system"

#Checking dpkg package is installed or not
	ee_echo "Checking if you have dpkg installed or not"
	if [[ ! -x /usr/bin/dpkg ]]; then
		ee_echo "Oh noo!! you don't have dpkg package. Let me install it for you, please wait.."
		apt-get -y install dpkg
	else
		ee_info "Dam you already have dpkg installed"	

fi
#CHECKING PHP5 PACKAGES/DEPENDENCIES/INSTALLING
	ee_echo "CheckING if you have PHP installed or not"
	dpkg -s php5 &>> /dev/null && dpkg -s php5-fpm &>> /dev/null

	if [ $? -ne 0 ]; then
	        ee_fail "I need to install php5 with it's dependencies, please wait.."
		 apt-get -y install php5 &>> /dev/null && apt-get -y install php5-fpm &>> /dev/null
	else
		ee_info "Dam !! you have PHP already installed"
	fi

#CHECKING MYSQL-SERVER PACKAGES/DEPENDENCIES/INSTALLING
		ee_echo "Checking if you have MYSQL installed or not"
		dpkg -s mysql-server &>> /dev/null
	if [ $? -ne 0 ]; then
		ee_fail "I need to install mysql-server, please wait..."

		ee_fail "I need to install mysql-server, please wait..."
	debconf-set-selections <<< 'mysql-server mysql-server/root_password password vipullinux'
	debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vipullinux'

	apt-get install -y mysql-server &>> /dev/null

	else
		ee_info "Dam!! MYSQL is already installed"
	fi
#CHECKING NGINX PACKAGES/DEPENDENCIES/INSTALLATION
		ee_echo "Checking if you have NGINX installed or not"
		dpkg -s nginx &>> /dev/null
	if [ $? -ne 0 ]; then
		ee_fail "I need to install nginx ,please wait.."
		apt-get install -y nginx &>> /dev/null
	else
		ee_info " Dam!! Nginx is already installed"
	fi
		ee_info "I have finished my first level"

#ASKING USER FOR DOMAIN NAME

read -p "Enter the domain name (eg.vipullinux.wordpress.com): " example_com 

	if [ ! -d "/var/www/$example_com" ]; then
		mkdir -p /var/www/$example_com
	fi
echo "127.0.0.1 $example_com" | sudo tee -a /etc/hosts &>> /dev/null 

#CREATING NGINX CONFIG FILES FOR EXAMPLE.COM
sudo tee /etc/nginx/sites-available/$example_com << EOF

	server {
		listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        root /var/www/html;
        index index.php index.html index.htm;

        server_name $example_com;

        location / {
                # try_files $uri $uri/ =404;
                try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
        }

        error_page 404 /404.html;

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
                root /usr/share/nginx/html;
        }

        location ~ \.php\$ {
                try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)\$;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params; 
			}
}
EOF

#sed -i "s/\(.*server_name\)\(.*\)/\1 ${example_com};/" /etc/nginx/sites-available/$example_com
ln -sF /etc/nginx/sites-available/$example_com /etc/nginx/sites-enabled/$example_com
service nginx restart >> $TEMP 2>&1
service php5-fpm restart >> $TEMP 2>&1
ee_fail "CHILL !! EVERY THINGS IS ALL RIGHT, IT WAS JUST A CONFIG FILE,I DON'T KNOW HOW TO PUT THIS IN BLACKHOLE[/DEV/NULL]"

#DOWNLOADING LATEST VERSION FROM WORDPRESS.ORG THEN UNZIP IT LOCALLY IN EXAMPLE COM/ DOCUMENT ROOM.

	ee_echo " I am going to download wordpress from http://wordpress.org/latest.tar.gip please wait.."
 cd ~ && wget http://wordpress.org/latest.tar.gz >> $TEMP 2>&1
	if [ $? -eq 0 ]; then
	ee_info "Done!! latest wordpress has been downloaded Successfully"
else
	ee_fail "ERROR:Failed to get latest tar file, Please check log files $TEMP" 1>&2
	fi

#EXTRACTING THE LATEST TAR FILES
	ee_echo "Let me extract the tar file"
cd ~ && tar xzvf latest.tar.gz &>> /dev/null && mv wordpress $example_com &>> /dev/null
	if [ $? -eq 0 ]; then
	ee_info "Your file has been rename and extracted Successfully"
cp -rf $example_com /var/www/$example_com
	fi 
#CREATING A NEW MYSQL-DATABASE FOR WORDPRESS,ADDRESS NAME MUST BE EXAMPLE_COM_DB
	db_name="_db"
	db_root_passwd="vipullinux"
mysql -u root -p$db_root_passwd << EOF
CREATE DATABASE ${example_com//./_}$db_name;
CREATE USER ${example_com//./_}@localhost;
SET PASSWORD FOR ${example_com//./_}@localhost=PASSWORD("password");
GRANT ALL PRIVILEGES ON ${example_com//./_}$db_name.* TO ${example_com//./_}@localhost IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
#exit;
EOF

	if [ $? -eq 0 ]; then
	ee_info "FINALLY YOUR DATABASE SETTING HAS BEEN SETUP"
	ee_info "Your database name assumed to be ${example_com//./_}$db_name "
 	ee_info "And Database password: password "
 else
	ee_fail "Ops!! something goes wrong, CONTACT sir.isac@gmail.com"
fi
#CREATING WP-CONFIG.PHP WITH PROPER DB CONFIGURATION.
cp /var/www/$example_com/wp-config-sample.php /var/www/$example_com/wp-config.php
sed -i "s/\(.*'DB_NAME',\)\(.*\)/\1'${example_com//./_}');/" /var/www/$example_com/wp-config.php
sed -i "s/\(.*'DB_USER',\)\(.*\)/\1'${example_com//./_}');/" /var/www/$example_com/wp-config.php
sed -i "s/\(.*'DB_PASSWORD',\)\(.*\)/\1'password');/" /var/www/$example_com/wp-config.php
service nginx restart >> $TEMP 2>&1
service php5-fpm restart >> $TEMP 2>&1

#UNDER DEVELOPMENT
