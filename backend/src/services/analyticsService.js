import crypto from "crypto";
import { config } from "../config/env.js";
import { logger } from "./loggerService.js";

class AnalyticsService {
  /**
   * Log a business event (e.g., "Recipe Generated", "Photo Scanned").
   * Anonymizes user ID before logging.
   */
  static logEvent(eventType, data, userId) {
    const event = {
      timestamp: new Date().toISOString(),
      type: eventType,
      // Anonymize User ID for general analytics (privacy first)
      // This allows us to track feature usage patterns without identifying individuals.
      user_hash: userId ? this.hashPii(userId) : "anonymous",
      metadata: this.sanitizeData(data),
      environment: config.env,
    };

    // In production, this would go to Datadog, Mixpanel, or Cloud Logging
    // For MVP, structured logging is captured by Docker/cloud aggregation services
    logger.structured("ANALYTICS", eventType, event);
  }

  /**
   * Log a compliance audit event (e.g., "Profile Update", "Data Export").
   * Requires actual User ID for audit trails (HIPAA/Security requirement).
   */
  static auditLog(action, userId, resourceId, status) {
    const auditRecord = {
      timestamp: new Date().toISOString(),
      level: "AUDIT",
      action: action,
      actor: userId,
      resource: resourceId,
      status: status,
    };

    logger.structured("AUDIT", action, auditRecord);
  }

  /**
   * Helper to hash sensitive data (PII)
   */
  static hashPii(data) {
    if (!data) return null;
    return crypto.createHash("sha256").update(data).digest("hex");
  }

  /**
   * Remove sensitive fields from metadata before logging
   */
  static sanitizeData(data) {
    if (!data) return {};
    const sanitized = { ...data };

    // List of fields to never log
    const sensitiveFields = ["password", "token", "email", "credit_card"];

    sensitiveFields.forEach((field) => {
      if (sanitized[field]) sanitized[field] = "[REDACTED]";
    });

    return sanitized;
  }
}

export default AnalyticsService;
