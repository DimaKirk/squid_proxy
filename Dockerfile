FROM debian:8 AS build
RUN apt-get -y update
RUN apt-get install -y curl supervisor git openssl  build-essential libssl-dev wget vim curl
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
WORKDIR /apps/
RUN wget -O - http://www.squid-cache.org/Versions/v4/squid-4.13.tar.gz | tar zxfv - \
    && CPU=$(( `nproc --all`-1 )) \
    && cd /apps/squid-4.13/ \
    && ./configure --prefix=/apps/squid --enable-icap-client --enable-ssl --with-openssl --enable-ssl-crtd --enable-auth --enable-basic-auth-helpers="NCSA" \
    && make -j$CPU \
    && make install \
    && cd /apps \
    && rm -rf /apps/squid-4.13
ADD . /apps/

RUN chown -R nobody:nogroup /apps/
RUN mkdir -p  /apps/squid/var/lib/
RUN /apps/squid/libexec/security_file_certgen -c -s /apps/squid/var/lib/ssl_db -M 4MB
RUN /apps/squid/sbin/squid -N -f /apps/squid.conf.cache -z
RUN chown -R nobody:nogroup /apps/
RUN chgrp -R 0 /apps && chmod -R g=u /apps

EXPOSE 3128
#CMD ["/usr/bin/supervisord"]
