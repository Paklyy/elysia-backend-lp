# Multi-stage build para imagem menor e builds mais rápidos
FROM oven/bun:1 AS base
WORKDIR /app

# Stage 1: Dependências
FROM base AS deps
# Copia apenas os arquivos necessários para instalar dependências
COPY package.json bun.lock ./
# Instala dependências (inclui devDependencies para build se necessário)
RUN bun install --frozen-lockfile

# Stage 2: Build (se necessário no futuro para transpilação)
FROM base AS build
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Se no futuro precisar de build, adicione aqui
# RUN bun run build

# Stage 3: Produção
FROM base AS production

# Cria usuário não-root para segurança
RUN addgroup --system --gid 1001 bun && \
    adduser --system --uid 1001 bun

# Copia apenas arquivos necessários para produção
COPY --from=deps /app/node_modules ./node_modules
COPY package.json bun.lock ./
COPY src ./src
COPY drizzle ./drizzle
COPY drizzle.config.ts ./
COPY tsconfig.json ./

# Altera ownership para o usuário bun
RUN chown -R bun:bun /app

# Muda para usuário não-root
USER bun

# Expõe a porta da aplicação
EXPOSE 3333

# Variáveis de ambiente padrão (podem ser sobrescritas)
ENV NODE_ENV=production
ENV PORT=3333

# Comando de saúde check (usa Bun para fazer requisição HTTP)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD bun --bun -e "fetch('http://localhost:3333/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

# Executa a aplicação
CMD ["bun", "run", "src/index.ts"]

