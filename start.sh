#!/bin/sh

if [ -z ${SSL_CERTIFICATE} ]; then
    SSL_CERTIFICATE=/etc/ssl/certs/snakeoil.pem
    SSL_CERTIFICATE_KEY=/etc/ssl/private/snakeoil.key

    if [ ! -e ${SSL_CERTIFICATE_KEY} ]; then
        openssl ecparam -out ${SSL_CERTIFICATE_KEY} -name prime256v1 -genkey
        echo "Private key file not found, generated a new one"
    fi
    if [ ! -e ${SSL_CERTIFICATE} ]; then
        openssl req -new -key ${SSL_CERTIFICATE_KEY} -x509 -sha256 -nodes \
            -days 3650 -subj "/CN=${SERVER_NAME:-localhost}" -out ${SSL_CERTIFICATE}
        echo "Certificate file not found, generated a new self-signed one"
    fi
fi

if [ "${IPV6}" = "yes" ]; then
    listen6_443="listen [::]:443 ssl default ipv6only=on;"
    listen6_80="listen [::]:80 default ipv6only=on;"
else
    listen6_443=""
    listen6_80=""
fi

cat > /etc/nginx/conf.d/proxy.conf << EOT
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 443 ssl default;
    ${listen6_443}

    server_name ${SERVER_NAME:-_};
    ssl_certificate ${SSL_CERTIFICATE};
    ssl_certificate_key ${SSL_CERTIFICATE_KEY};

    location / {
        client_body_buffer_size ${CLIENT_BODY_BUFFER_SIZE:-128k};
        client_max_body_size ${CLIENT_MAX_BODY_SIZE:-16m};

        proxy_set_header Host ${PROXY_HOST:-\$host};
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Port \$server_port;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        proxy_pass ${PROXY_PASS:-http://upstream};
        proxy_redirect ${PROXY_REDIRECT:-default};

        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;

        proxy_buffering ${PROXY_BUFFERING:-off};
        proxy_connect_timeout ${PROXY_CONNECT_TIMEOUT:-60s};
        proxy_read_timeout ${PROXY_READ_TIMEOUT:-180s};
        proxy_send_timeout ${PROXY_SEND_TIMEOUT:-60s};
    }
}

server {
    listen 80 default;
    ${listen6_80}

    server_name ${SERVER_NAME:-_};
    return 301 https://\$server_name\$request_uri;
}
EOT

exec nginx -g 'daemon off;'
