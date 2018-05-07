FROM centos:7.3.1611
MAINTAINER jv <gjw15546192557@gmail.com>

ENV NGINX_VERSION 1.10.2
ENV PHP_VERSION 7.1.9
ENV REDIS_VERSION 3.1.4

# base wordspace
WORKDIR /usr/local/src

# install lib
RUN yum install -y epel-release &&  yum clean all && \
    yum install -y \
    yum install -y m4 \
    yum install -y autoconf \
    yum install -y zip unzip \
    gcc gcc-c++ make wget \
    zlib-devel \
    openssl-devel \
    pcre-devel \
    libxml2-devel \
    libcurl-devel \
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libmcrypt-devel  && \
    yum clean all  && \
    useradd -M -s /sbin/nologin www && \
    # get tar package
    wget -c -O nginx.tar.gz http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    wget -c -O php.tar.gz http://php.net/distributions/php-$PHP_VERSION.tar.gz && \
    wget -c -O nginx_cache_purge.tar.gz http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz && \
tar -zxf nginx.tar.gz && \
     cd nginx-$NGINX_VERSION && \
    ./configure --prefix=/usr/local/nginx \
    --user=www --group=www \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --with-http_gzip_static_module && \
    make && make install && make clean && rm -rf nginx.tar.gz  && cd .. && \
tar zxf php.tar.gz && \
     cd php-$PHP_VERSION && \
    ./configure --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-config-file-scan-dir=/usr/local/php/etc/php.d \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mcrypt=/usr/include \
    --with-mysqli \
    --with-pdo-mysql \
    --with-openssl \
    --with-gd \
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-png-dir \
    --with-jpeg-dir \
    --with-freetype-dir \
    --with-xmlrpc \
    --with-mhash \
    --enable-fpm \
    --enable-xml \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-mbstring \
    --enable-gd-native-ttf \
    --enable-mysqlnd \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --enable-fileinfo \
    --disable-rpath \
    --enable-ipv6 && \
    make && make install && make clean && rm -rf php.tar.gz && cd .. && \
#cp ./php-$PHP_VERSION/php.ini-production /usr/local/php/etc/php.ini && \
mv /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
#mv /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf  && \
rm -rf /usr/local/src/*

RUN ln  -s  /usr/local/php/bin/php    /usr/bin/php && \
    ln  -s  /usr/local/php/bin/phpize    /usr/bin/phpize && \
    ln  -s  /usr/local/nginx/sbin/nginx    /usr/bin/nginx && \
    mkdir -p /etc/nginx/conf.d && \
    mkdir -p /app && chown -R www:www /app
#覆盖nginx.conf文件
ADD conf/nginx.conf /usr/local/nginx/conf/nginx.conf
ADD php.ini /usr/local/php/etc/php.ini
ADD php-fpm.conf /usr/local/php/etc/php-fpm.d/www.conf

# libkafka
RUN wget  https://github.com/edenhill/librdkafka/archive/master.zip && \
    unzip master.zip && \
    rm -f master.zip && \
    cd librdkafka-master && \
    ./configure --enable-ssl --enable-sasl && \
    make && make install

#RUN cd ~ && \
#    wget -c -O autoconf.tar.gz  http://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz && \
#    tar xzvf autoconf.tar.gz && \
#    cd autoconf-* && \
#    ./configure && \
#    make && make install


# redis extensions
#RUN wget https://github.com/phpredis/phpredis/archive/$REDIS_VERSION.tar.gz && \
#    tar -zxvf $REDIS_VERSION.tar.gz && \
#    cd phpredis-$REDIS_VERSION && \
#    /usr/local/php/bin/phpize && \
#    ./configure --with-php-config=/usr/local/php/bin/php-config && \
#    make && make install && \

RUN /usr/local/php/bin/pecl install redis

RUN /usr/local/php/bin/pecl install rdkafka

#sed -i 's/^;date\.timezone[ ]*=[ ]*/&Asia\/Shanghai/' php.ini
RUN yum remove -y gcc gcc-c++ make wget \
                      zlib-devel \
                      openssl-devel \
                      pcre-devel \
                      libxml2-devel \
                      libcurl-devel \
                      libpng-devel \
                      libjpeg-devel \
                      freetype-devel \
                      libmcrypt-devel \
                      m4 \
                      autoconf \
                      zip \
                      unzip \
                      epel-release && \
                      yum clean all



ADD start.sh /start.sh
RUN chmod 755 /start.sh && \
    sed -i 's/^;date\.timezone[ ]*=[ ]*/date\.timezone = Asia\/Shanghai/' /usr/local/php/etc/php.ini  && \
    sed -i 's/^session\.use_strict_mode = 0/session\.use_strict_mode = 1/' /usr/local/php/etc/php.ini  && \
    sed -i 's/^session\.cookie_httponly =/session\.cookie_httponly = 1/' /usr/local/php/etc/php.ini && \
    sed -i '$a\extension=rdkafka.so' /usr/local/php/etc/php.ini && \
    sed -i '$a\extension=redis.so' /usr/local/php/etc/php.ini
WORKDIR /app

VOLUME ["/app"]

#Set port
EXPOSE 80 443

#Start it
ENTRYPOINT ["/start.sh"]
