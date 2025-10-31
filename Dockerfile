# ============================================
# Dockerfile para Elysia Backend (compilado)
# ============================================
# Este Dockerfile usa multi-stage build para:
# 1. Instalar dependências com Bun
# 2. Compilar a aplicação para binário standalone
# 3. Rodar o binário em imagem leve (Alpine Linux)
# ============================================

# Stage 1: Dependências
# Usa Bun para instalar as dependências
FROM oven/bun:1 AS deps
WORKDIR /app

# Copia apenas arquivos de dependências para cache otimizado
COPY package.json bun.lock ./
# Instala todas as dependências (incluindo devDependencies para build)
RUN bun install --frozen-lockfile

# Stage 2: Build
# Compila a aplicação Elysia para binário standalone
FROM oven/bun:1 AS build
WORKDIR /app

# Copia dependências instaladas do stage anterior
COPY --from=deps /app/node_modules ./node_modules

# Copia arquivos de configuração e código fonte
COPY package.json bun.lock ./
COPY tsconfig.json ./
COPY drizzle.config.ts ./
COPY src ./src
COPY drizzle ./drizzle

# Compila a aplicação para binário standalone
# O binário será gerado como ./server na raiz do projeto
RUN bun build --compile --minify-whitespace --minify-syntax --outfile server src/index.ts

# Stage 3: Runtime
# Usa Alpine para imagem leve com ferramentas necessárias para health checks
# Alternativa: distroless (mais seguro, mas sem ferramentas de rede)
FROM alpine:latest AS runtime

WORKDIR /app

# Instala certificados CA para requisições HTTPS (se necessário)
# e ferramentas básicas para health checks
RUN apk --no-cache add ca-certificates wget && \
    # Cria usuário não-root para segurança
    addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copia apenas o binário compilado (e assets estáticos se houver)
COPY --from=build --chown=appuser:appgroup /app/server ./server

# Muda para usuário não-root
USER appuser

# Expõe a porta da aplicação
# A porta padrão é 3333, mas pode ser sobrescrita via variável PORT
EXPOSE 3333

# Define variáveis de ambiente padrão
# IMPORTANTE: No Coolify ou PaaS, defina PORT e outras variáveis via UI/config
ENV NODE_ENV=production
ENV PORT=3333

# Health check - verifica o endpoint /hello
# Ajuste o endpoint e porta conforme sua rota de health check
# Nota: A variável PORT é lida pela aplicação, mas o health check usa porta fixa
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3333/hello || exit 1

# Executa o binário compilado
# O binário standalone não precisa de Bun ou Node.js instalado
CMD ["./server"]
