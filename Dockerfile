# --- Base Stage ---
FROM oven/bun:1-slim AS base
WORKDIR /app

# --- Dependencies Stage (instala deps sem código) ---
FROM base AS deps
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# --- Build Stage (compila TS) ---
FROM base AS build
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN bun build src/index.ts --outdir dist

# --- Production Stage ---
FROM base AS production
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3333

COPY package.json bun.lock ./
RUN bun install --production --frozen-lockfile

COPY --from=build /app/dist ./dist
COPY drizzle ./drizzle
COPY drizzle.config.ts ./

USER bun
EXPOSE 3333

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD bun --bun -e "fetch('http://localhost:' + process.env.PORT + '/health').then(r => r.ok ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))"

CMD ["bun", "run", "dist/index.js"]
