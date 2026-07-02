#!/bin/bash
# =============================================================================
# ZACON - Script de inicialização do Let's Encrypt
# =============================================================================

set -e

# Configurações
DOMAIN="zaconcontabilidade.com.br"
EMAIL="contato@zaconcontabilidade.com.br"
DATA_PATH="./certbot"
RSA_KEY_SIZE=4096
STAGING=0 # Mude para 1 para testar sem usar quota do Let's Encrypt

# Verifica se os certificados já existem
if [ -d "$DATA_PATH/conf/live/$DOMAIN" ]; then
    echo "Certificados já existem para $DOMAIN"
    read -p "Deseja substituir os certificados existentes? (y/N) " decision
    if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
        exit 0
    fi
fi

# Cria diretórios necessários
mkdir -p "$DATA_PATH/www"
mkdir -p "$DATA_PATH/conf"

# Parâmetros do staging
if [ $STAGING != "0" ]; then
    staging_arg="--staging"
fi

echo "### Baixando parâmetros TLS recomendados..."
if [ ! -e "$DATA_PATH/conf/options-ssl-nginx.conf" ] || [ ! -e "$DATA_PATH/conf/ssl-dhparams.pem" ]; then
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$DATA_PATH/conf/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$DATA_PATH/conf/ssl-dhparams.pem"
fi

echo "### Criando certificado dummy para $DOMAIN..."
path="/etc/letsencrypt/live/$DOMAIN"
mkdir -p "$DATA_PATH/conf/live/$DOMAIN"
docker compose run --rm --entrypoint "\
    openssl req -x509 -nodes -newkey rsa:$RSA_KEY_SIZE -days 1 \
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot

echo "### Iniciando nginx..."
docker compose up --force-recreate -d nginx

echo "### Removendo certificado dummy..."
docker compose run --rm --entrypoint "\
    rm -Rf /etc/letsencrypt/live/$DOMAIN && \
    rm -Rf /etc/letsencrypt/archive/$DOMAIN && \
    rm -Rf /etc/letsencrypt/renewal/$DOMAIN.conf" certbot

echo "### Solicitando certificado Let's Encrypt para $DOMAIN..."
docker compose run --rm --entrypoint "\
    certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    --email $EMAIL \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --rsa-key-size $RSA_KEY_SIZE \
    --agree-tos \
    --force-renewal" certbot

echo "### Recarregando nginx..."
docker compose exec nginx nginx -s reload

echo "### Certificados instalados com sucesso!"
