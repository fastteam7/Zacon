#!/bin/bash
# =============================================================================
# ZACON - Deploy Produção
# Atualiza repositório, submódulo, limpa caches e reconstrói todo o ambiente
# =============================================================================

set -Eeuo pipefail

echo "=========================================="
echo "      ZACON - DEPLOY PRODUÇÃO"
echo "=========================================="

# -----------------------------------------------------------------------------
# Descobre automaticamente os caminhos
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SUBMODULE_DIR="$ROOT_DIR/ZaconF"

cd "$ROOT_DIR"

echo ""
echo "Projeto.......: $ROOT_DIR"
echo "Frontend......: $SUBMODULE_DIR"

# -----------------------------------------------------------------------------
# Verificações
# -----------------------------------------------------------------------------
command -v docker >/dev/null || { echo "ERRO: Docker não encontrado."; exit 1; }
command -v git >/dev/null || { echo "ERRO: Git não encontrado."; exit 1; }

# Verifica se o arquivo .env existe (necessário para variáveis do CMS)
if [ ! -f "$ROOT_DIR/.env" ]; then
    echo ""
    echo "ERRO: Arquivo .env não encontrado!"
    echo "Copie .env.example para .env e configure as variáveis:"
    echo "  cp $ROOT_DIR/.env.example $ROOT_DIR/.env"
    echo ""
    echo "Variáveis necessárias:"
    echo "  - CMS_API_KEY"
    echo "  - CMS_WEBHOOK_SECRET"
    exit 1
fi

# -----------------------------------------------------------------------------
# Atualiza repositório principal
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Atualizando repositório principal..."
echo "=========================================="

git fetch origin
git checkout main
git reset --hard origin/main
git clean -fd -e .env

# -----------------------------------------------------------------------------
# Atualiza submódulo
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Atualizando submódulo ZaconF..."
echo "=========================================="

git submodule update --init --recursive

cd "$SUBMODULE_DIR"

git fetch origin
git checkout main
git reset --hard origin/main
git clean -fd

echo ""
echo "Versão ZaconF:"
git rev-parse --short HEAD

cd "$ROOT_DIR"

# -----------------------------------------------------------------------------
# Remove cache local do Next (caso exista)
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Limpando cache local do Next.js..."
echo "=========================================="

rm -rf "$SUBMODULE_DIR/.next" 2>/dev/null || true

# -----------------------------------------------------------------------------
# Para containers e remove imagens
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Parando ambiente Docker..."
echo "=========================================="

docker compose down --remove-orphans --rmi all || true

# -----------------------------------------------------------------------------
# Remove cache de build do Docker
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Limpando cache do Docker..."
echo "=========================================="

docker builder prune -af

# -----------------------------------------------------------------------------
# Reconstrói tudo do zero
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Reconstruindo imagens..."
echo "=========================================="

docker compose build --no-cache

# -----------------------------------------------------------------------------
# Sobe ambiente
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Subindo containers..."
echo "=========================================="

docker compose up -d

# -----------------------------------------------------------------------------
# Aguarda aplicação iniciar
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Aguardando aplicação iniciar..."
echo "=========================================="

APP_OK=0

for i in {1..30}; do
    if curl -fs http://localhost:3000 >/dev/null 2>&1; then
        APP_OK=1
        break
    fi

    echo "Tentativa $i/30..."
    sleep 5
done

if [ "$APP_OK" -ne 1 ]; then
    echo ""
    echo "ERRO: aplicação não respondeu."

    echo ""
    echo "================ LOGS APP ================"
    docker logs zacon-app --tail=200 || true

    echo ""
    echo "============== LOGS NGINX ================"
    docker logs zacon-nginx --tail=100 || true

    exit 1
fi

echo ""
echo "✓ Aplicação iniciada."

# -----------------------------------------------------------------------------
# Limpa cache do Nginx
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Limpando cache do Nginx..."
echo "=========================================="

docker exec zacon-nginx sh -c "rm -rf /var/cache/nginx/* && nginx -s reload" || true

sleep 2

# -----------------------------------------------------------------------------
# Teste final
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Validando aplicação..."
echo "=========================================="

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)

if [ "$HTTP_CODE" != "200" ]; then
    echo ""
    echo "ERRO: aplicação respondeu HTTP $HTTP_CODE"

    echo ""
    echo "================ LOGS APP ================"
    docker logs zacon-app --tail=200 || true

    exit 1
fi

# -----------------------------------------------------------------------------
# Informações finais
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "DEPLOY CONCLUÍDO COM SUCESSO!"
echo "=========================================="

echo ""
echo "Projeto Principal:"
cd "$ROOT_DIR"
git rev-parse --short HEAD

echo ""
echo "ZaconF:"
cd "$SUBMODULE_DIR"
git rev-parse --short HEAD

echo ""
echo "Containers:"
docker compose ps

echo ""
echo "Acesse:"
echo "https://zacon.com.br"