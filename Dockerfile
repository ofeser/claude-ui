FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ---

FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev && node scripts/fix-node-pty.js || true

COPY --from=builder /app/dist ./dist
COPY server ./server
COPY shared ./shared
COPY scripts ./scripts

ENV SERVER_PORT=3001
ENV HOST=0.0.0.0
ENV DATABASE_PATH=/data/auth.db

VOLUME ["/data"]
EXPOSE 3001

CMD ["node", "server/index.js"]
