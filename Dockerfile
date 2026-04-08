FROM node:22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY package*.json ./
COPY scripts ./scripts
RUN npm ci

COPY . .
RUN npm run build

# ---

FROM node:22-alpine

RUN apk add --no-cache bash && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup -h /home/appuser

RUN npm install -g @anthropic-ai/claude-code @google/gemini-cli @openai/codex cursor-agent

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY server ./server
COPY shared ./shared
COPY scripts ./scripts

RUN mkdir -p /data && chown appuser:appgroup /data /app

ENV SERVER_PORT=3001
ENV HOST=0.0.0.0
ENV DATABASE_PATH=/data/auth.db

VOLUME ["/data"]
EXPOSE 3001

USER appuser

CMD ["node", "server/index.js"]
