#!/usr/bin/env bash

# ---------------------------------------
#          Virtual Machine Setup
# ---------------------------------------

# Adding multiverse sources.
#cat > /etc/apt/sources.list.d/multiverse.list << EOF
#deb http://security.ubuntu.com/ubuntu trusty-security multiverse
#EOF


# Updating packages
apt-get update

# ---------------------------------------
#          Apache Setup
# ---------------------------------------

# Installing Packages
apt-get install -y apache2

# linking Vagrant directory to Apache 2.4 public directory
#rm -rf /var/www
#ln -fs /vagrant /var/www/html

# Add ServerName to httpd.conf
#echo "ServerName localhost" > /etc/apache2/httpd.conf
# Setup hosts file
#VHOST=$(cat <<EOF
#<VirtualHost *:80>
#  DocumentRoot "/var/www/html"
#  ServerName localhost
#  <Directory "/var/www/html">
#    AllowOverride All
#  </Directory>
#</VirtualHost>
#EOF
#)
#echo "${VHOST}" > /etc/apache2/sites-enabled/000-default.conf

# modifify AllowOverride
sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\n\t<Directory \/var\/www\/html>\n\t\tOptions Indexes FollowSymLinks\n\t\tAllowOverride All\n\t\tRequire all granted\n\t<\/Directory>\n/' /etc/apache2/sites-available/000-default.conf

# Loading needed modules to make apache work
a2enmod actions fastcgi rewrite
service apache2 reload

# ---------------------------------------
#          PHP Setup
# ---------------------------------------

# Installing packages
apt-get install -y php5 php5-cli php5-fpm curl php5-curl php5-mcrypt php5-xdebug libapache2-mod-php5 php5-gd php5-ldap php5-pgsql libphp-phpmailer libphp-phpmailer

# Creating the configuration for Xdebug	
cat > /etc/php5/apache2/conf.d/20-xdebug.ini << EOF
zend_extension=xdebug.so
xdebug.default_enable=1
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_connect_back=1
xdebug.remote_port=9000
xdebug.remote_autostart=1
EOF

# Setting the umask to 777 remeber it is on reverse	
cat >> /etc/apache2/envvars << EOF
umask 000
EOF

# user www-data
usermod -G33 vagrant
usermod -Gvagrant www-data

# Creating the configurations inside Apache
#cat > /etc/apache2/conf-available/php5-fpm.conf << EOF
#<IfModule mod_fastcgi.c>
#    AddHandler php5-fcgi .php
#    Action php5-fcgi /php5-fcgi
#    Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
#    FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -socket /var/run/php5-fpm.sock -pass-header Authorization

    # NOTE: using '/usr/lib/cgi-bin/php5-cgi' here does not work,
    #   it doesn't exist in the filesystem!
#    <Directory /usr/lib/cgi-bin>
#        Require all granted
#    </Directory>

#</IfModule>
#EOF

# Enabling php modules
#php5enmod mcrypt

# Triggering changes in apache
#a2enconf php5-fpm
service apache2 restart

# ---------------------------------------
#          MySQL Setup
# ---------------------------------------

# Setting MySQL root user password root/root
debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'

# Installing packages
apt-get install -y mysql-server mysql-client php5-mysql php5-mssql
mysql -pvagrant -e "USE mysql; UPDATE user set host='%' WHERE user='root' AND host='127.0.0.1'; FLUSH PRIVILEGES;"
sed -i 's/bind-address/# bind-address/' /etc/mysql/my.cnf 
sed -i 's/skip-external-locking/# skip-external-locking/' /etc/mysql/my.cnf 

service mysql restart
service apache2 restart

# ---------------------------------------
#          PHPMyAdmin setup
# ---------------------------------------

# Default PHPMyAdmin Settings
#debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
#debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root'
#debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root'
#debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root'
#debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'

# Install PHPMyAdmin
#apt-get install -y phpmyadmin

# Make Composer available globally
#ln -s /etc/phpmyadmin/apache.conf /etc/apache2/sites-enabled/phpmyadmin.conf

# Restarting apache to make changes
#service apache2 restart



# ---------------------------------------
#       Tools Setup.
# ---------------------------------------
# These are some extra tools that you can remove if you will not be using them 
# They are just to setup some automation to your tasks. 

# Adding NodeJS from Nodesource. This will Install NodeJS Version 5 and npm
#curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
#sudo apt-get install -y nodejs

# Installing Bower and Gulp
#npm install -g bower gulp

# Installing GIT
apt-get install -y git

# Install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod 777 /usr/local/bin/composer
