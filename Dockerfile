FROM php:apache

RUN a2enmod rewrite expires headers substitute

RUN mkdir -p /usr/kerberos \
	&& ln -s /usr/lib/x86_64-linux-gnu/ /usr/kerberos/lib \
	&& ln -s /usr/lib64/x86_64-linux-gnu/ /usr/kerberos/lib64
# install the PHP extensions we need
RUN apt-get update && apt-get upgrade -y && apt-get install -y libpng12-dev libjpeg-dev zlib1g-dev libcurl4-gnutls-dev libssl-dev libc-client2007e-dev libkrb5-dev less sudo unzip \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
	&& docker-php-ext-install gd mysqli opcache zip bcmath pdo pdo_mysql curl imap

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
	
RUN { \
		echo 'file_uploads=On'; \
		echo 'upload_max_filesize=64M'; \
		echo 'post_max_size=64M'; \
		echo 'max_execution_time=600'; \
	} > /usr/local/etc/php/conf.d/php-recommended.ini

WORKDIR /var/www

RUN curl -o limesurvey.zip -SL https://www.limesurvey.org/stable-release?download=1884:limesurvey2543%20161014zip \
	&& unzip limesurvey.zip -d /var/www \
	&& rm -r /var/www/html \
	&& mv /var/www/limesurvey /var/www/html \
	&& chown -R www-data:www-data /var/www/html
  
EXPOSE 80
CMD ["apache2-foreground"]
