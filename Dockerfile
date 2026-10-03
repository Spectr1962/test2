# --- Этап 1: Сборка приложения ---
FROM node:20-alpine AS builder
WORKDIR /app

# 1. Сразу копируем все файлы проекта (включая папку prisma) в контейнер
COPY . .

# 2. Устанавливаем все зависимости (теперь Prisma точно увидит schema.prisma)
RUN npm ci --legacy-peer-deps

# 3. Собираем Next.js проект
RUN npm run build

# --- Этап 2: Финальный продакшн-образ ---
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Копируем всё готовое из этапа сборки
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

EXPOSE 3001
CMD ["npm", "start"]
