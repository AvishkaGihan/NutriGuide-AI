import { logger } from "../services/loggerService.js";

/**
 * Custom Error Class for Operational Errors.
 * Used to distinguish between programming bugs (Crash) and expected errors (404, 400).
 */
export class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith("4") ? "fail" : "error";
    this.isOperational = true; // Signals this is a known, handled error

    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Async Handler Wrapper.
 * Wraps async route handlers to automatically catch errors and pass them to Express error middleware.
 * Prevents the need for try/catch blocks in every controller.
 * * Usage: router.get('/', asyncHandler(async (req, res, next) => { ... }))
 */
export const asyncHandler = (fn) => {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
};

/**
 * Standard HTTP Status Codes mapping for readability
 */
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
};

/**
 * Formatting utility for development vs production error responses.
 * (This logic is often called by the error middleware)
 */
export const formatErrorResponse = (err, environment = "development") => {
  if (environment === "development") {
    return {
      status: err.status || "error",
      error: err,
      message: err.message,
      stack: err.stack,
    };
  }

  // Production: Don't leak stack traces
  if (err.isOperational) {
    // Trusted operational error: send message to client
    return {
      status: err.status,
      message: err.message,
    };
  }

  // Programming or other unknown error: don't leak details
  // Log it server-side for monitoring
  logger.error("Unhandled error detected", err);
  return {
    status: "error",
    message: "Something went wrong. Please try again later.",
  };
};
