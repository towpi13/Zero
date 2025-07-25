# ========================================
# Base Stage: Alpine Linux with Node.js and Bun
# ========================================
FROM node:22-alpine AS base

# Install bash, curl, and unzip, needed for Bun's installer
RUN apk add --no-cache bash curl unzip

# Install Bun system-wide
# This defines where bun will be installed and adds it to the PATH
ENV BUN_INSTALL="/usr/local"
RUN curl -fsSL https://bun.sh/install | bash

# Verify bun is installed and available in the PATH
RUN bun --version


# ========================================
# Dependencies Stage: Install Dependencies (Unchanged)
# ========================================
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install turbo globally (still uses pnpm)
RUN npm install -g pnpm
RUN pnpm install -g turbo

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
RUN mkdir -p apps packages
COPY apps/*/package.json ./apps/
COPY packages/ ./packages/

# Install dependencies (still uses pnpm)
RUN pnpm install --prod --ignore-scripts


# ========================================
# Builder Stage: Build the Application (Updated)
# ========================================
FROM base AS builder
WORKDIR /app

# Install global tools: pnpm, wrangler, and drizzle-kit
RUN npm install -g pnpm wrangler drizzle-kit

# Copy workspace configuration and source code
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY . .

ENV CI=true

# Install all dependencies (still uses pnpm)
RUN pnpm install --frozen-lockfile

# Set environment variables for build
ENV NEXT_TELEMETRY_DISABLED=1 \
    NODE_ENV=production \
    DOCKER_BUILD=true

# Build the application (still uses pnpm)
RUN cd apps/mail && pnpm run build

# ========================================
# Runner Stage: Production Environment (Unchanged)
# ========================================
FROM base AS runner
WORKDIR /app

RUN npm install -g wrangler

RUN addgroup -S -g 1001 pnpm && \
    adduser -S -u 1001 nextjs -G pnpm

# Set environment variables for build
ENV NODE_ENV=production \
    PORT=3000 \
    HOSTNAME="0.0.0.0" \
    NEXT_TELEMETRY_DISABLED=1

# Copy entrypoint and run it
COPY scripts/docker/ /app/scripts
RUN chmod -R +x /app/scripts/*

# Copy the entire built application
COPY --from=builder --chown=nextjs:pnpm /app ./

# Switch to non-root user
USER nextjs

# Set server port and host
EXPOSE 3000

# Start the server (still uses original entrypoint)
CMD ["/app/scripts/entrypoint.sh"]