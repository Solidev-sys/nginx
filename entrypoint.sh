#!/bin/bash
set -e

NGINX_DIR="/home/escritorio/nginx"
CONF_DIR="$NGINX_DIR/conf.d"
SSL_DIR="$NGINX_DIR/ssl"

if [ ! -d "$NGINX_DIR" ]; then
  echo "📁 Creando estructura inicial en $NGINX_DIR ..."
  mkdir -p "$CONF_DIR" "$SSL_DIR"
fi

if [ ! -f "$NGINX_DIR/nginx.conf" ]; then
  cat > "$NGINX_DIR/nginx.conf" <<'EOF'
user  nginx;
worker_processes  auto;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    include /etc/nginx/conf.d/*.conf;
}
EOF
fi

if [ ! -f "$CONF_DIR/solidev.conf" ]; then
  cat > "$CONF_DIR/solidev.conf" <<'EOF'
server {
    listen 443 ssl;
    server_name www.solidev.com solidev.com;

    ssl_certificate     /etc/ssl/private/solidev.crt;
    ssl_certificate_key /etc/ssl/private/solidev.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://solidev-frontend:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
fi

if [ ! -f "$SSL_DIR/solidev.crt" ]; then
  touch "$SSL_DIR/solidev.crt"
fi

if [ ! -f "$SSL_DIR/solidev.key" ]; then
  touch "$SSL_DIR/solidev.key"
fi

echo "🚀 Estructura lista. Iniciando NGINX..."
exec "$@"
