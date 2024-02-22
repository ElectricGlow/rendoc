FROM php:7.4-apache

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
   mv composer.phar /usr/local/bin/composer
   

RUN apt-get update && apt-get install -y \
    curl \
    git \
    libapache2-mod-php7.4 \
    php7.4-mysql \
    libbz2-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libpng-dev \
    libreadline-dev \
    libzip-dev \
    libpq-dev \
    unzip \
    zip \
 && rm -rf /var/lib/apt/lists/*
  
RUN a2enmod rewrite
# نصب PHP و ماژول های مورد نیاز
  

# نصب MySQL و ایجاد دیتابیس
RUN apt-get install -y mysql-server
RUN service mysql start && mysql -e "CREATE DATABASE renderdb;"

# فعال سازی mysqli
RUN docker-php-ext-install mysqli

# نصب و راه اندازی PHPMyAdmin
RUN apt-get install -y phpmyadmin
RUN ln -s /etc/phpmyadmin/apache.conf /etc/apache2/sites-enabled/phpmyadmin.conf
RUN service apache2 restart





COPY ./deploy/ /var/www/html

WORKDIR /var/www/html

RUN mkdir ./src

RUN composer install --prefer-dist
RUN composer dump-autoload --optimize


RUN composer update

# RUN php vendor/bin/doctrine orm:convert-mapping --namespace="" --force --from-database yml ./config/yaml

# RUN php vendor/bin/doctrine orm:generate-entities --generate-annotations=false --update-entities=true --generate-methods=false ./src

# RUN composer update

# تنظیمات وب سرور
EXPOSE 80 443
EXPOSE 3306

# Définir l'entrée de l'application
CMD ["apache2-foreground"]











