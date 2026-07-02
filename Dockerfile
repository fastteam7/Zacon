# =============================================================================
# ZACON Contabilidade - Dockerfile
# Multi-stage build para Next.js 15
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Dependencies
# -----------------------------------------------------------------------------
FROM node:20-alpine AS deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copia os arquivos de dependências do subdiretório ZaconF
COPY ZaconF/package.json ZaconF/package-lock.json* ./

# Instala dependências
RUN npm ci --legacy-peer-deps

# -----------------------------------------------------------------------------
# Stage 2: Builder
# -----------------------------------------------------------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copia dependências do stage anterior
COPY --from=deps /app/node_modules ./node_modules

# Copia o código fonte do ZaconF
COPY ZaconF/ ./

# Variáveis de ambiente para build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build da aplicação
RUN npm run build

# -----------------------------------------------------------------------------
# Stage 3: Runner (Produção)
# -----------------------------------------------------------------------------
FROM node:20-alpine AS runner

WORKDIR /app

# Cria usuário não-root para segurança
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Variáveis de ambiente
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Copia arquivos necessários para produção
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Copia o build standalone (se existir) ou o .next completo
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# Define usuário não-root
USER nextjs

# Expõe a porta
EXPOSE 3000

# Comando de inicialização
CMD ["npm", "start"]
