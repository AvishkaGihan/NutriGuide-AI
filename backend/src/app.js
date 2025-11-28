import express from "express";
import cors from "cors";
import helmet from "helmet";
import { config } from "./config/env.js";
import { checkDatabaseHealth } from "./config/database.js";
import { requestLogger } from "./middleware/logging.js";
import {
  globalErrorHandler,
  notFoundHandler,
} from "./middleware/errorHandler.js";

// Import Routes
import authRoutes from "./routes/auth.js";
import chatRoutes from "./routes/chat.js";
import photoRoutes from "./routes/photos.js";
import recipeRoutes from "./routes/recipes.js";
import userRoutes from "./routes/user.js";

// Initialize Express App
const app = express();

// 1. Global Middleware
// Security headers
app.use(helmet());

// CORS configuration (allow frontend to connect)
app.use(
  cors({
    origin: "*", // For MVP/Development. In production, restrict to your Flutter web domain or specific IPs
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

// Body parsing (JSON and URL-encoded)
app.use(express.json({ limit: "10mb" })); // Limit body size to prevent DoS
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Request logging
app.use(requestLogger);

// 2. Health Check Endpoint (useful for Docker/Cloud deployment)
app.get("/health", async (req, res) => {
  const dbHealth = await checkDatabaseHealth();
  res.status(200).json({
    status: "ok",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    database: dbHealth.status,
    environment: config.env,
  });
});

// 3. API Routes
// Mount all route modules under /api/v1
app.use(`${config.apiPrefix}/auth`, authRoutes);
app.use(`${config.apiPrefix}/chat`, chatRoutes);
app.use(`${config.apiPrefix}/photos`, photoRoutes);
app.use(`${config.apiPrefix}/recipes`, recipeRoutes);
app.use(`${config.apiPrefix}/user`, userRoutes);

// 4. 404 Handler (for unknown routes)
app.use(notFoundHandler);

// 5. Global Error Handler (must be last)
app.use(globalErrorHandler);

// 6. Start Server
// Only start if this file is run directly (not imported for testing)
if (process.env.NODE_ENV !== "test") {
  app.listen(config.port, async () => {
    console.log(
      `\n🚀 NutriGuide Server running in ${config.env} mode on port ${config.port}`
    );
    console.log(`➜  Health Check: http://localhost:${config.port}/health`);
    console.log(
      `➜  API Base:     http://localhost:${config.port}${config.apiPrefix}`
    );

    // Check DB Connection on startup
    const dbStatus = await checkDatabaseHealth();
    console.log(
      `📦 Database:     ${
        dbStatus.status === "healthy" ? "Connected ✅" : "Failed ❌"
      }`
    );
  });
}

export default app;
