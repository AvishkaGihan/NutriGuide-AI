import morgan from "morgan";
import { config } from "../config/env.js";

/**
 * Custom token to ensure we don't log sensitive PII in URLs if passed as query params
 * (Though architectural best practice is to pass PII in body, not query params)
 */
morgan.token("safe-url", (req) => {
  // Basic example: limit URL length in logs to prevent massive overflow
  return req.originalUrl.length > 200
    ? req.originalUrl.substring(0, 200) + "..."
    : req.originalUrl;
});

// Define formats
const devFormat =
  ":method :safe-url :status :response-time ms - :res[content-length]";
const prodFormat =
  "[:date[iso]] :method :safe-url :status :response-time ms - :res[content-length] - :remote-addr";

// Determine format based on environment
const logFormat = config.env === "production" ? prodFormat : devFormat;

// Configuration options
const options = {
  // Skip logging for health checks to reduce noise in monitoring
  skip: (req) => req.url === "/health" || req.url === "/favicon.ico",
};

// Export the configured middleware
export const requestLogger = morgan(logFormat, options);
