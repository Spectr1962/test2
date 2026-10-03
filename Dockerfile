# --- Этап 1: Сборка приложения ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./

# Устанавливаем абсолютно все зависимости (и дев, и продакшн)
RUN npm ci --legacy-peer-deps

COPY . .
# Собираем Next.js проект
RUN npm run build

# --- Этап 2: Финальный продакшн-образ ---
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Вместо повторной установки просто копируем ВСЁ готовое из этапа сборки
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/dist ./dist

EXPOSE 3001
CMD ["npm", "start"]
