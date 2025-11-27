import { config } from "../config/env.js";
import { formatErrorResponse } from "../utils/errorHandler.js";

/**
 * Global Error Handling Middleware.
 * Must take 4 arguments (err, req, res, next) to be recognized as an error handler by Express.
 */
export const globalErrorHandler = (err, req, res, _next) => {
  // Default to 500 Internal Server Error if status not set
  err.statusCode = err.statusCode || 500;
  err.status = err.status || "error";

  // 1. Log the error for debugging
  // In production, you might want to send this to a service like Sentry or Datadog
  if (config.env === "development" || err.statusCode === 500) {
    console.error("🔥 ERROR LOG:", {
      message: err.message,
      stack: err.stack,
      url: req.originalUrl,
      method: req.method,
    });
  }

  // 2. Format the response based on environment
  const response = formatErrorResponse(err, config.env);

  // 3. Send response
  res.status(err.statusCode).json(response);
};

/**
 * Catch-all for 404 Not Found (routes that don't exist)
 */
export const notFoundHandler = (req, res, next) => {
  const error = new Error(`Route not found - ${req.originalUrl}`);
  error.statusCode = 404;
  next(error);
};
