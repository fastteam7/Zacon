#!/bin/bash
# =============================================================================
# ZACON - Deploy Produção
# Sempre utiliza a versão mais recente do submódulo ZaconF
# =============================================================================

set -Eeuo pipefail

echo "=========================================="
echo "      ZACON - DEPLOY PRODUÇÃO"
echo "=========================================="

ROOT_DIR="$(pwd)"
SUBMODULE_DIR="ZaconF"

echo ""
echo "### Atualizando repositório principal..."
git fetch origin
git checkout main
git reset --hard origin/main

echo ""
echo "### Inicializando submódulo (caso necessário)..."
git submodule update --init

echo ""
echo "### Atualizando ZaconF para a última versão da branch main..."

cd "$SUBMODULE_DIR"

git fetch origin
git checkout main
git reset --hard origin/main
git pull origin main

echo "ZaconF atualizado para:"
git rev-parse --short HEAD

cd "$ROOT_DIR"

echo ""
echo "### Reconstruindo containers..."
docker compose down --remove-orphans

docker compose build --no-cache

echo ""
echo "### Iniciando aplicação..."
docker compose up -d

echo ""
echo "### Aguardando aplicação iniciar..."
sleep 15

echo ""
echo "### Health Check..."

for i in {1..15}; do
    if curl -fs http://localhost:3000 >/dev/null; then
        echo "✓ Aplicação online!"
        break
    fi

    echo "Tentativa $i/15..."
    sleep 5
done

if ! curl -fs http://localhost:3000 >/dev/null; then
    echo ""
    echo "ERRO: aplicação não respondeu."

    echo ""
    echo "===== LOGS ====="
    docker compose logs --tail=100

    exit 1
fi

echo ""
echo "### Limpando imagens antigas..."
docker image prune -af

echo ""
echo "=========================================="
echo "Deploy concluído com sucesso!"
echo "=========================================="

echo ""
echo "Versão atual:"
echo "Projeto Principal : $(git rev-parse --short HEAD)"

cd "$SUBMODULE_DIR"
echo "ZaconF            : $(git rev-parse --short HEAD)"
cd "$ROOT_DIR"