#!/bin/sh

/usr/local/php/sbin/php-fpm
/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf

#tail -f /start.sh
