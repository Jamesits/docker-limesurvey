FROM php:apache

RUN a2enmod rewrite expires headers substitute

# install the PHP extensions we need
RUN apt-get update && apt-get upgrade -y && apt-get install -y libpng12-dev libjpeg-dev zlib1g-dev libcurl4-gnutls-dev less sudo \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-configure imap --with-imap-ssl \
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

VOLUME /var/www/html
WORKDIR /var/www/html

RUN curl -o limesurvey.zip -SL https://www.limesurvey.org/stable-release?download=1884:limesurvey2543%20161014zip \
	&& unzip limesurvey.zip -D /var/www/html \
	&& rm limesurvey.zip \
	&& chown -R www-data:www-data /var/www/html
  
EXPOSE 80
CMD ["apache2-foreground"]
