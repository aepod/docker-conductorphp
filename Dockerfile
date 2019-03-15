ARG php_version=5.6
FROM php:${php_version}-fpm

ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=webuser --with-fpm-group=nginx --disable-cgi

LABEL maintainer="Mathew Beane <mathew.beane@rmgmedia.com>"

# Install Base Packages
RUN apt-get update && apt-get install -y \
  apt-transport-https \
  apt-utils \
  git \
  gnupg \
  libcurl3-dev \
  libfreetype6-dev \
  libjpeg-dev \
  libmcrypt-dev \
  libpng-dev \
  libxml2-dev \
  libxslt-dev \
  mysql-client \
  mydumper \
  nano \
  openssh-client \
  telnet \
  unzip \
  vim \
  zip \
  zlib1g-dev && rm -rf /var/lib/apt/lists/*
  
# Install PHP Extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib \
  && docker-php-ext-install bcmath ctype curl dom exif fileinfo gd iconv intl json mbstring \
     mcrypt opcache pdo_mysql soap xsl zip

# xdebug comes from pecl
RUN pecl install xdebug-2.5.3

# zlib has a broken bit - workaround https://github.com/docker-library/php/issues/233#issuecomment-288727629
RUN docker-php-ext-install zlib; exit 0
RUN cp /usr/src/php/ext/zlib/config0.m4 /usr/src/php/ext/zlib/config.m4
RUN docker-php-ext-install zlib

# Ioncube what a pain
WORKDIR /root/
RUN curl -sS https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube_loader.tgz \
 && tar -zxvf ioncube_loader.tgz \
 && cp /root/ioncube/ioncube_loader_lin_5.6.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/ioncube_loader_lin_5.6.so \
 && rm -rf ioncube*

# Configure PHP
COPY config/php.ini /usr/local/etc/php/php.ini
  
# Setup webuser
RUN groupadd -g 800 nginx
RUN useradd -d /home/webuser -m -u 1000 -g 800 webuser
RUN chown webuser /var/www
  







