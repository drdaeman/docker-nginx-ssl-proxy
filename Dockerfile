FROM nginx:mainline-alpine
MAINTAINER Aleksey Zhukov <drdaeman@drdaeman.pp.ru>

ENV PROXY_PASS=http://upstream
ENV IPV6=yes
COPY start.sh /start.sh
RUN chmod +x /start.sh && rm /etc/nginx/conf.d/*.conf && apk add --no-cache openssl

ENTRYPOINT ["/start.sh"]
