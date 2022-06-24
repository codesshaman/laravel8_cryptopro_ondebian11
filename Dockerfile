FROM debian:11.3

# Загружаю id нового пользователя в окружение:

ENV USER_ID=1000

# Переключаюсь на суперпользователя:

USER root

# Устанавливаю весь необходимый софт:

RUN apt update && apt install -y \
    wget libboost-dev sqlite3 \
    curl mc autoconf tar nano \
    libxml2-dev gcc libonig-dev\
    libsqlite3-dev sqlite3 \
    make g++ patch g++ sudo \
    php-dev zlib1g-dev php-fpm

# Устанавливаю рабочий каталог и копирую все нужные файлы:

WORKDIR /tmp

COPY ./sources .

# Создаю пользователя с тем же UID, что и в системе:

RUN groupadd user && useradd --create-home user -g user && \
    sed -i "s/user:x:1000:1000/user:x:${USER_ID}:${USER_ID}/g" /etc/passwd && \
    echo "user  ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Устанавливаю КриптоПРО:

RUN cd /tmp/linux-amd64_deb && chmod +x install.sh && ./install.sh && \
    dpkg -i lsb-cprocsp-devel_5.0.12500-6_all.deb && cd /tmp/cades_linux-amd64 && \
    dpkg -i cprocsp-pki-phpcades-64_2.0.14589-1_amd64.deb && \
    dpkg -i cprocsp-pki-cades-64_2.0.14589-1_amd64.deb && \
    cp /tmp/php7_sources/php-7.4.28.tar.gz /opt && cd /opt && \
    tar -xvzf php-7.4.28.tar.gz && mv php-7.4.28 php && rm /opt/php-7.4.28.tar.gz && \
    cd /opt/php/ ./configure --prefix=/opt/php --enable_fpm && \
    rm /opt/cprocsp/src/phpcades/Makefile.unix && cp /tmp/Makefile.unix /opt/cprocsp/src/phpcades/ && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10 && \
    cp /tmp/php7_support.patch/php7_support.patch /opt/cprocsp/src/phpcades && \
    cd /opt/cprocsp/src/phpcades && patch -p0 < ./php7_support.patch
    # eval `/opt/cprocsp/src/doxygen/CSP/../setenv.sh --64` && make -f Makefile.unix && \
    # cp /opt/cprocsp/src/phpcades/libphpcades.so $(php -i | grep 'extension_dir => ' | awk '{print $3}')/phpcades.so
    # ln -s /opt/cprocsp/src/phpcades/libphpcades.so $(php -i | grep 'extension_dir => ' | awk '{print $3}')/libcppcades.so && \
    # echo 'extension=phpcades.so' >> /etc/php/7.4/cli/php.ini 

#   sed -i "s/;listen.all/listen.all/g" /etc/php/7.4/fpm/pool.d/www.conf

#  Открываю рабочий порт:

EXPOSE 9000

# Переключаюсь на созданного пользователя:

# USER user

# CMD ["service" "php7.4-fpm" "start"]

# Проверка:
# php --re php_CPCSP

# Устанавливаю php-fpm

# RUN cd /tmp/php7_sources && dpkg -i php-fpm_7.4+76_all.deb && \
#    service php7.4-fpm start && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# apt install -y php-fpm && service php7.4-fpm start && \
# echo 'listen.allowed_clients = 127.0.0.1' >> /etc/php/7.4/fpm/pool.d/www.conf && \

# CMD ["php-fpm7.4"]

# CMD ["php-fpm","-F"]

# Переключаюсь на созданного пользователя и открываю рабочий порт:

# /var/log/php7.4-fpm.log

# USER user

