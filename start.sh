#!/bin/sh
php-fpm -D
nginx -g "daemon off;" &
dufs -p 7522 -A -a admin:admin@/:rw
