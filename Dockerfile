# --- Base Stage ---
# Use the official Bun image. The "slim" variant is smaller and good for production.
FROM oven/bun:1-slim AS base
WORKDIR /app

# --- Install Stage ---
# This stage installs ALL dependencies, including devDependencies.
# We might use this stage in the future if you add a build step (e.g., transpiling TS to JS).
FROM base AS install
WORKDIR /app
# Copy only the package files
COPY package.json bun.lockb ./
# Install all dependencies based on the lockfile
RUN bun install --frozen-lockfile

# --- Production Stage ---
# This is the final image we will use.
FROM base AS production
WORKDIR /app

# Set production environment
ENV NODE_ENV=production
# Set a default port. Coolify will override this with its own PORT variable.
ENV PORT=3333

# Create a dedicated, non-root user and group for security
RUN addgroup --system --gid 1001 bun && \
    adduser --system --uid 1001 bun

# Copy ONLY the necessary files to install production dependencies
COPY package.json bun.lockb ./

# Install ONLY production dependencies. This makes the image much smaller.
RUN bun install --production --frozen-lockfile

# Copy the application code
# We copy this *after* installing dependencies to leverage Docker's cache.
COPY src ./src
COPY drizzle ./drizzle
COPY drizzle.config.ts ./
COPY tsconfig.json ./

# Change ownership of the entire /app directory to the non-root user
RUN chown -R bun:bun /app

# Switch to the non-root user
USER bun

# Expose the port the app will run on
EXPOSE 3333

# --- Healthcheck ---
# This check ensures your app is actually running and healthy.
# It uses the $PORT environment variable to be flexible.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD bun --bun -e "fetch('http://localhost:' + process.env.PORT + '/health').then(r => r.ok ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))"

# --- Start Command ---
# This command is from your package.json "start" script
CMD ["bun", "run", "src/index.ts"]