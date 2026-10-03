import { PrismaClient } from "../../generated/prisma/index.js";
import { Pool } from "pg";
import { PrismaPg } from "@prisma/adapter-pg";
import { env } from "~/env";

const createPrismaClient = () => {
  // 1. Создаем пул подключений pg к PostgreSQL
  const pool = new Pool({ connectionString: env.DATABASE_URL });
  
  // 2. Создаем адаптер Prisma для PostgreSQL
  const adapter = new PrismaPg(pool);

  // 3. Передаем адаптер в конструктор PrismaClient, как того требует Prisma 7
  return new PrismaClient({
    adapter,
    log: env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
  });
};

const globalForPrisma = globalThis as unknown as {
  prisma: ReturnType<typeof createPrismaClient> | undefined;
};

export const db = globalForPrisma.prisma ?? createPrismaClient();

if (env.NODE_ENV !== "production") globalForPrisma.prisma = db;
