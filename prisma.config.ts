import { defineConfig } from '@prisma/config';

export default defineConfig({
    datasource: {
        // Подтягиваем строку подключения из переменных окружения
        url: process.env.DATABASE_URL,
    },
});
