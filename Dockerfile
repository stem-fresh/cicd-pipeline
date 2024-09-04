# Base image
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
# Install necessary packages
RUN apk add --no-cache libc6-compat && \
    apk update

# Set working directory
WORKDIR /app

# Install pnpm globally, pinning a specific version
RUN npm install -g pnpm@7.13.2

# Install dependencies based on the preferred package manager
COPY package.json pnpm-lock.yaml* ./
# Optionally remove the postinstall script if it's not needed
RUN pnpm pkg delete scripts.postinstall
RUN pnpm install --frozen-lockfile

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Use the appropriate environment file for the build
#COPY .env.dev .env

RUN pnpm build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

# RUN addgroup --system --gid 1001 nodejs && \
# adduser --system --uid 1001 nextjs

# USER nextjs

EXPOSE 3000

# ENV PORT 3000
# ENV HOSTNAME "0.0.0.0"
# ENV AUTH_TRUST_HOST true

# Add a health check to monitor the container's status
# HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:3000/ || exit 1

# server.js is created by next build from the standalone output
CMD ["pnpm", "start"]
