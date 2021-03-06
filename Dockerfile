FROM ubuntu:14.04

RUN apt-get update -qq && apt-get install -y -qq\
  apache2 \
  php5 \
  php5-cli \
  php5-gd \
  php5-mysql \
  php-pear \
  php5-curl \
  postfix \
  sudo \
  rsync \
  git-core \
  unzip \
  wget \
  mysql-client

RUN adduser --system --group --home /var/aegir aegir
RUN adduser aegir www-data
RUN a2enmod rewrite
RUN ln -s /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf
RUN ln -s /etc/apache2/conf-available/aegir.conf /etc/apache2/conf-enabled/aegir.conf

COPY sudoers-aegir /etc/sudoers.d/aegir
RUN chmod 0440 /etc/sudoers.d/aegir

RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- --quiet
RUN cp composer.phar /usr/local/bin/composer

RUN wget http://files.drush.org/drush.phar -O - -q > /usr/local/bin/drush
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/drush

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY docker-entrypoint-tests.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-tests.sh

VOLUME /var/aegir

USER aegir

ENV AEGIR_CLIENT_NAME admin
ENV AEGIR_CLIENT_EMAIL aegir@aegir.docker
ENV AEGIR_MAKEFILE /var/aegir/.drush/provision/aegir.make

# docker-entrypoint.sh waits for mysql and runs hostmaster install
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["drush @hostmaster hosting-queued"]