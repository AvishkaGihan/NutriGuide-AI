import dotenv from "dotenv";
import Joi from "joi";

// Load environment variables from .env file
dotenv.config();

// Define a schema to validate the environment variables
const envSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid("development", "production", "test")
    .default("development"),

  PORT: Joi.number().default(3000),

  API_PREFIX: Joi.string().default("/api/v1"),

  // Database (PostgreSQL)
  DATABASE_URL: Joi.string()
    .required()
    .description("PostgreSQL Connection String"),

  // Caching (Redis) - Optional for MVP start, but good to have ready
  REDIS_URL: Joi.string().allow("").default("redis://localhost:6379"),

  // Authentication (JWT)
  JWT_SECRET: Joi.string()
    .required()
    .description("Secret key for signing Access Tokens"),
  JWT_REFRESH_SECRET: Joi.string()
    .required()
    .description("Secret key for signing Refresh Tokens"),
  JWT_ACCESS_EXPIRATION: Joi.string().default("15m"),
  JWT_REFRESH_EXPIRATION: Joi.string().default("7d"),

  // AI Services (Google Gemini)
  GEMINI_API_KEY: Joi.string().required().description("Google Gemini API Key"),

  // Logging
  LOG_LEVEL: Joi.string()
    .valid("error", "warn", "info", "http", "debug")
    .default("info"),
}).unknown(); // Allow other variables in .env that aren't defined here

// Validate the process.env against the schema
const { value: envVars, error } = envSchema.validate(process.env, {
  abortEarly: false, // Report all errors, not just the first one
});

if (error) {
  const missingFields = error.details.map((x) => x.message).join(", ");
  throw new Error(`Config validation error: ${missingFields}`);
}

// Export the validated configuration object
export const config = {
  env: envVars.NODE_ENV,
  port: envVars.PORT,
  apiPrefix: envVars.API_PREFIX,
  db: {
    url: envVars.DATABASE_URL,
  },
  redis: {
    url: envVars.REDIS_URL,
  },
  jwt: {
    secret: envVars.JWT_SECRET,
    refreshSecret: envVars.JWT_REFRESH_SECRET,
    accessExpiration: envVars.JWT_ACCESS_EXPIRATION,
    refreshExpiration: envVars.JWT_REFRESH_EXPIRATION,
  },
  gemini: {
    apiKey: envVars.GEMINI_API_KEY,
  },
  logging: {
    level: envVars.LOG_LEVEL,
  },
};
