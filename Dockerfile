FROM node:20 AS dev
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /app

COPY . .
RUN pnpm install --no-frozen-lockfile && \
    chown -R node:node /app

USER node
ENV TURBO_TELEMETRY_DISABLED=1
EXPOSE 3000
CMD ["pnpm", "dev"]