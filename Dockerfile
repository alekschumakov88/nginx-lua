FROM debian:8.8
RUN apt-get update \
    && buildDeps="autoconf \
        g++ \
        gcc \
        libpcre3-dev \
        libperl-dev \
        libssl-dev \
        make \
    " \
    && apt-get install -y \
        $buildDeps \
        file \
        pkg-config \
        libpcre3 \
        libpcrecpp0 \
        libperl5.20 \
        libssl1.0.0 \
        wget \
    && wget -O /usr/src/lua.tar.gz http://luajit.org/download/LuaJIT-2.0.4.tar.gz \
    && mkdir -p /usr/src/luajit \
    && tar -xzf /usr/src/lua.tar.gz -C /usr/src/luajit --strip-components=1 \
    && cd /usr/src/luajit \
    && make \
    && make install \
    && rm -f /usr/src/lua.tar.gz \
    && wget -O /usr/src/ngx_devel_kit.tar.gz https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz \
    && mkdir /usr/src/ngx_devel_kit \
    && tar -xzf /usr/src/ngx_devel_kit.tar.gz -C /usr/src/ngx_devel_kit --strip-components=1 \
    && rm -rf /usr/src/ngx_devel_kit.tar.gz \
    && wget https://github.com/openresty/lua-nginx-module/archive/v0.9.16.tar.gz -O /usr/src/lua-nginx-module.tar.gz \
    && mkdir /usr/src/lua-nginx-module \
    && tar -xzf /usr/src/lua-nginx-module.tar.gz -C /usr/src/lua-nginx-module --strip-components=1 \
    && rm -f /usr/src/lua-nginx-module.tar.gz \
    && mkdir -p /usr/src/nginx \
    && wget -O /usr/src/nginx.tar.gz "http://nginx.org/download/nginx-1.13.2.tar.gz" \
    && tar -xzf /usr/src/nginx.tar.gz -C /usr/src/nginx --strip-components=1 \
    && rm -rf /usr/src/nginx.tar.gz \
    && cd /usr/src/nginx \
    && ./configure \
        --prefix=/var/lib/nginx \
        --sbin-path=/usr/local/sbin/nginx \
        --modules-path=/usr/local/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/tmp/nginx/body \
        --http-proxy-temp-path=/var/tmp/nginx/proxy \
        --http-fastcgi-temp-path=/var/tmp/nginx/fcgi \
        --user=wwwbm \
        --group=wwwbm \
        --with-pcre-jit \
        --with-http_dav_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_gzip_static_module \
        --with-http_v2_module \
        --with-http_auth_request_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_auth_request_module \
        --with-threads \
        --with-stream \
        --with-http_slice_module \
        --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
        --add-module=/usr/src/ngx_devel_kit \
        --add-module=/usr/src/lua-nginx-module \
    && make -j"$(nproc)" \
    && make install \
    && cd / \
    && rm -rf /usr/src/nginx \
    && strip --strip-all /usr/local/sbin/nginx \
    && apt-get purge $buildDeps \
    && localepurge && apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && mkdir -p \
        /var/tmp/nginx/body \
        /var/tmp/nginx/proxy \
        /var/tmp/nginx/fcgi
CMD ["nginx", "-g", "daemon off;"]