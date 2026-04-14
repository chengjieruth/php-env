FROM php:8.2-fpm-alpine

# 切换为国内镜像源（加速下载）
RUN sed -i 's#https\?://dl-cdn.alpinelinux.org/alpine#https://mirrors.aliyun.com/alpine#g' /etc/apk/repositories

# 安装 nginx 和 APCu 所需的依赖（通过 PECL 安装）
RUN apk add --no-cache nginx \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .build-deps

# 复制 nginx 配置
RUN echo 'server { \
    listen 80; \
    root /var/www/html; \
    index index.php; \
    location ~ \.php$ { \
        fastcgi_pass 127.0.0.1:9000; \
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \
        include fastcgi_params; \
    } \
}' > /etc/nginx/http.d/default.conf

# 配置 APCu
RUN echo "apc.enabled=1" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
    && echo "apc.shm_size=32M" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

# 启动脚本：先启 php-fpm，再启 nginx
COPY start.sh /
COPY dufs /usr/local/bin/
RUN chmod +x /start.sh && chmod +x /usr/local/bin/dufs
WORKDIR /var/www/html
EXPOSE 80

CMD ["/start.sh"]

