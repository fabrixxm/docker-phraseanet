FROM php:5-fpm

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
RUN mkdir -p /usr/share/man/man1

# http://stackoverflow.com/a/37426929
RUN sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list

# First command is from: http://stackoverflow.com/a/37426929
RUN sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list \
    && apt-get update && apt-get install -y --no-install-recommends --fix-missing \
        nano \
        imagemagick \
        libevent-dev \
        ufraw \
        ghostscript \
        xpdf \
        poppler-utils \
        unoconv \
        gpac \
        swftools \
        openjdk-8-jre \
        openjdk-8-jdk \
        locales \
        pkg-config \
        libxml2-dev \
        libexpat1-dev \
#        libzmq-dev \ #Conflicts with libzmq3-dev
        libzmq3-dev \
        re2c \
        scons \
        inkscape \
        python-setuptools \
#        libmemcache0 \
        libimage-exiftool-perl \
        git \
        libfreetype6-dev \
        libgif-dev \
        libjpeg62-turbo-dev \
        cachefilesd \
        autoconf \
        automake \
        build-essential \
        libass-dev \
        libfreetype6-dev \
        libgpac-dev \
        libsdl1.2-dev \
        libtheora-dev \
        libtool \
        libva-dev \
        libvdpau-dev \
        libvorbis-dev \
        libx11-dev \
        libxext-dev \
        libx264-dev \
        libxfixes-dev \
        libgsm1-dev \
        pkg-config \
        texi2html \
        zlib1g-dev \
        yasm \
        unzip \
        libopus-dev \
        libvpx-dev \
        libvorbis-dev \
        libmp3lame-dev \
        libxvidcore-dev \
        libfaad-dev \
        libopencore-amrnb-dev \
        libopencore-amrwb-dev \
        libxvidcore-dev \
        libdc1394-22-dev \
        libav-tools \
        libmariadbclient-dev \
        # libmysqlclient-dev \
        # PHP requirements:
        libicu-dev libpng-dev libjpeg-dev libenchant-dev libmcrypt-dev libmagickwand-dev libcurl3-dev \
    && docker-php-ext-configure gd --enable-gd-native-ttf --with-jpeg-dir=/usr/lib/x86_64-linux-gnu --with-png-dir=/usr/lib/x86_64-linux-gnu \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl mcrypt curl gd enchant mbstring pcntl pdo_mysql zip sockets gettext exif \
    && pecl install imagick \
    && docker-php-ext-enable imagick

RUN pecl install zmq-beta \
    && docker-php-ext-enable zmq \
    && apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /opt/php/phraseanet2 \
#     && curl -sL "https://github.com/alchemy-fr/Phraseanet-Extension/archive/master.tar.gz" | tar --strip-components=1 -xzC /opt/php/phraseanet2 \
#     && cd /opt/php/phraseanet2 \
#     && phpize \
#     && ./configure \
#     && make \
#     && make install \
#     && docker-php-ext-enable phrasea2.so \
#     && cd / && rm -rf /opt/php/phraseanet2

# RUN mkdir /opt/phraseanet_indexer \
#     && curl -sL "https://github.com/alchemy-fr/Phraseanet-Indexer/archive/master.tar.gz" | tar --strip-components=1 -xzC /opt/phraseanet_indexer \
#     && cd /opt/phraseanet_indexer \
#     && autoreconf --force --install \
#     && ./configure \
#     && make \
#     && make install \
#     && cd / && rm -rf /opt/phraseanet_indexer

RUN printf 'date.timezone=Europe/Berlin\nsession.cache_limiter=off\nshort_open_tag=off\nsession.hash_function=on\nsession.hash_bits_per_character=6\ndisplay_errors=off\n' > /usr/local/etc/php/conf.d/docker-php-phraseanet.ini

RUN rm -rf /var/www/html \
    && cd /var/www \
    && curl -sL https://www.phraseanet.com/builds/alchemy-fr-Phraseanet-v4.0.2.zip > phrasea.zip \
    && unzip -q phrasea.zip \
    && rm phrasea.zip \
    && mv Phraseanet html \
    && cd html \
    && chown -R www-data:www-data /var/www/html

# Docker stuff
RUN curl -sL "https://raw.githubusercontent.com/netresearch/retry/master/retry" -o /usr/local/bin/retry \
    && chmod +x /usr/local/bin/retry

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN printf "display_errors=on\ndisplay_startup_errors=on\n" >> /usr/local/etc/php/conf.d/docker-php-phraseanet.ini \
    && { \
       echo "php_flag[display_errors] = on"; \
       echo "php_admin_value[error_reporting] = E_ALL"; \
       echo "php_admin_value[error_log] = /var/log/php5-fpm.log"; \
    } | tee /usr/local/etc/php-fpm.d/zz-phrasea.conf

ENV ADMIN_EMAIL "admin@example.com"
ENV ADMIN_PASSWORD "admin"
ENV WEB_HOST "localhost"
ENV DB_HOST "localhost"
ENV DB_APP_NAME "phraseanet_app"
ENV DB_DATA_NAME "phraseanet_data"
ENV DB_USER "phraseanet"
ENV DB_PASSWORD "db_password_123"

EXPOSE 9000

WORKDIR /var/www/html
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
