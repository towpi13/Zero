FROM node:20 AS dev
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /app

COPY . .
RUN pnpm install --no-frozen-lockfile

EXPOSE 3000
EXPOSE 8787
CMD ["pnpm", "nizzy", "sync"]
CMD ["pnpm", "build"]
CMD ["pnpm", "start"]
