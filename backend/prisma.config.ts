import "dotenv/config";
import { defineConfig, env } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    // URL database untuk keperluan migrasi (Prisma Migrate)
    url: env("DATABASE_URL"),
  },
});