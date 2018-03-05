#!/usr/bin/env bash

#== Import script args ==

sudo apt-get update

timezone=$(echo "$1")

#== Bash helpers ==

function info {
  echo " "
  echo "--> $1"
  echo " "
}

#== Provision script ==

info "Provision-script user: `whoami`"

export DEBIAN_FRONTEND=noninteractive

info "Configure timezone"
timedatectl set-timezone ${timezone} --no-ask-password
# Preparamos la configuracion de Debian para que no pida
# la insercion de password del usuario root al instalar Mysql
info "Prepare root password for MySQL"
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password \"''\""
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password \"''\""
echo "Done!"

info "Update OS software"
apt-get update
apt-get upgrade -y

info "Install additional software"


apt-get install -y php5 php5-mcrypt php5-curl git mysql-server vim php5-cli php5-fpm curl php5-xdebug php5-mysql libapache2-mod-php5 php5-gd php5-pgsql php5-intl vim


# Creating the configuration for Xdebug	
cat > /etc/php5/apache2/conf.d/20-xdebug.ini << EOF
zend_extension=xdebug.so
xdebug.default_enable=1
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_connect_back=1
xdebug.remote_port=9000
xdebug.remote_autostart=1
xdebug.max_nesting_level=250
EOF

# Setting the umask to 777 remeber it is on reverse	
cat >> /etc/apache2/envvars << EOF
umask 000
EOF

# user www-data
#usermod -G33 vagrant
#usermod -Gvagrant www-data
#usermod -a -G dialout vagrant

#Setting user vagrant into group dialout. It's group that you create vm and to synced_folder
usermod -G33 dialout
usermod -a -G dialout vagrant
usermod -Gvagrant www-data

service apache2 restart

info "Configure MySQL"
sed -i "s/.*bind-address.*/# bind-address = 0.0.0.0/" /etc/mysql/my.cnf
sed -i "s/.*skip-external-locking/# skip-external-locking/" /etc/mysql/my.cnf

mysql -uroot <<< "CREATE USER 'root'@'%' IDENTIFIED BY ''"
mysql -uroot <<< "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'"
mysql -uroot <<< "DROP USER 'root'@'localhost'"
mysql -uroot <<< "FLUSH PRIVILEGES"
echo "Done!"

# info "Configure PHP-FPM"
# sed -i 's/user = www-data/user = vagrant/g' /etc/php/7.0/fpm/pool.d/www.conf
# sed -i 's/group = www-data/group = vagrant/g' /etc/php/7.0/fpm/pool.d/www.conf
# sed -i 's/owner = www-data/owner = vagrant/g' /etc/php/7.0/fpm/pool.d/www.conf
# echo "Done!"

# info "Configure NGINX"
# sed -i 's/user www-data/user vagrant/g' /etc/nginx/nginx.conf
# echo "Done!"

# info "Enabling site configuration"
# ln -s /app/vagrant/nginx/app.conf /etc/nginx/sites-enabled/app.conf
# echo "Done!"


info "Install composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
sed -i 's/# export LS_OPTIONS=/export LS_OPTIONS='
# eval "`dircolors`"


