#!/bin/bash
# =============================================================================
# ZACON - Script de Deploy
# Execute no servidor de produção após git pull
# =============================================================================

set -e

echo "=========================================="
echo "  ZACON - Deploy"
echo "=========================================="

# Atualiza submodules
echo "### Atualizando submodules..."
git submodule update --init --recursive

# Build da aplicação
echo "### Building application..."
docker compose build --no-cache

# Para containers existentes
echo "### Parando containers..."
docker compose down

# Inicia novos containers
echo "### Iniciando containers..."
docker compose up -d

# Aguarda containers iniciarem
echo "### Aguardando containers..."
sleep 10

# Health check
echo "### Verificando saúde da aplicação..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✓ Aplicação está respondendo"
else
    echo "✗ Aplicação não está respondendo"
    docker compose logs app
    exit 1
fi

# Limpa imagens antigas
echo "### Limpando imagens antigas..."
docker image prune -f

echo "=========================================="
echo "  Deploy concluído com sucesso!"
echo "=========================================="
