import { config } from "../config/env.js";

/**
 * Centralized Logger Service
 * Provides consistent, structured logging across the backend.
 * Replaces console.log/console.error to enable:
 * - Environment-aware log levels
 * - Cloud Logging integration (GCP, AWS CloudWatch, etc.)
 * - Structured JSON format for log aggregation tools (Datadog, Splunk, etc.)
 */
class LoggerService {
  // Private constructor - this is a singleton
  constructor() {
    this.environment = config.env;
  }

  /**
   * Log a debug message (only in development)
   */
  debug(message, metadata = {}) {
    if (this.environment === "development") {
      console.debug(`[DEBUG] ${message}`, metadata);
    }
  }

  /**
   * Log an informational message
   */
  info(message, metadata = {}) {
    console.log(`[INFO] ${message}`, metadata);
  }

  /**
   * Log a warning
   */
  warn(message, metadata = {}) {
    console.warn(`[WARN] ${message}`, metadata);
  }

  /**
   * Log an error with stack trace
   */
  error(message, error = null, metadata = {}) {
    const errorData = {
      message,
      ...(error && {
        errorMessage: error.message,
        errorStack: error.stack,
      }),
      ...metadata,
    };

    console.error(`[ERROR] ${message}`, errorData);

    // In production, here you would send to Sentry, Datadog, GCP Cloud Logging, etc.
    // Example: Sentry.captureException(error, { extra: metadata });
  }

  /**
   * Create structured log entry for analytics/audit
   */
  structured(level, message, data = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      environment: this.environment,
      ...data,
    };

    console.log(JSON.stringify(logEntry));
  }
}

// Export singleton instance
export const logger = new LoggerService();
