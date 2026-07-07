# =============================================================================
# ZACON Contabilidade - Dockerfile
# Multi-stage build otimizado para Next.js 15 com standalone output
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
# Stage 3: Runner (Produção - Standalone otimizado)
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

# Copia arquivos públicos
COPY --from=builder /app/public ./public

# Copia o build standalone (muito mais leve)
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Define usuário não-root
USER nextjs

# Expõe a porta
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Comando de inicialização (standalone server)
CMD ["node", "server.js"]
