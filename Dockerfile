# ==========================================
# ЭТАП 1: Сборка TypeScript приложения
# ==========================================
FROM node:20-alpine AS builder

# Указываем рабочую директорию внутри контейнера
WORKDIR /app

# Копируем файлы конфигурации зависимостей
COPY package*.json ./

# Устанавливаем ВСЕ зависимости (включая typescript и devDependencies)
RUN npm ci

# Копируем все исходные файлы проекта
COPY . .

# Компилируем TypeScript в JavaScript (код улетит в папку dist или build)
RUN npm run build


# ==========================================
# ЭТАП 2: Финальный продакшн-образ
# ==========================================
FROM node:20-alpine AS runner

WORKDIR /app

# Выставляем переменную окружения для Node.js в режим продакшна
ENV NODE_ENV=production

# Копируем package.json, чтобы поставить только чистые dependencies
COPY package*.json ./

# Устанавливаем ТОЛЬКО продакшн-зависимости (без devDependencies)
RUN npm ci --only=production --legacy-peer-deps

# Копируем скомпилированный JavaScript из первого этапа сборки
# (Если у вас в tsconfig.json указана другая папка вместо dist, замените dist на неё)
COPY --from=builder /app/dist ./dist

# Открываем ваш порт 3001 для внешнего мира
EXPOSE 3001

# Команда для запуска приложения из скомпилированной папки
CMD ["node", "dist/index.js"]
