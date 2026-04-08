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

RUN apk add --no-cache bash

RUN npm install -g @anthropic-ai/claude-code

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
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
