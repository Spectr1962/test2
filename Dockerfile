# --- Этап 1: Сборка приложения ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY . .

# Принимаем аргументы сборки от GitHub Actions для прохождения валидации Next.js
ARG DATABASE_URL
ARG AUTH_SECRET
ARG AUTH_GOOGLE_ID
ARG AUTH_GOOGLE_SECRET
ARG AUTH_YANDEX_ID
ARG AUTH_YANDEX_SECRET
ARG AUTH_VK_ID
ARG AUTH_VK_SECRET

# Переводим аргументы в системные переменные среды для сборщика
ENV DATABASE_URL=$DATABASE_URL
ENV AUTH_SECRET=$AUTH_SECRET
ENV AUTH_GOOGLE_ID=$AUTH_GOOGLE_ID
ENV AUTH_GOOGLE_SECRET=$AUTH_GOOGLE_SECRET
ENV AUTH_YANDEX_ID=$AUTH_YANDEX_ID
ENV AUTH_YANDEX_SECRET=$AUTH_YANDEX_SECRET
ENV AUTH_VK_ID=$AUTH_VK_ID
ENV AUTH_VK_SECRET=$AUTH_VK_SECRET

RUN npm ci --legacy-peer-deps
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
