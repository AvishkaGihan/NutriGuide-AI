import jwt from "jsonwebtoken";
import { config } from "../config/env.js";
import { AppError } from "../utils/errorHandler.js";

// In a production app, use Redis to store blacklisted tokens
// For MVP, we'll demonstrate the interface.
// import redisClient from '../config/redis.js';

class JwtService {
  /**
   * Generate a short-lived Access Token (usually 15 mins)
   * Used for authenticating API requests.
   */
  static generateAccessToken(user) {
    const payload = {
      id: user.id,
      email: user.email,
      type: "access",
    };

    return jwt.sign(payload, config.jwt.secret, {
      expiresIn: config.jwt.accessExpiration,
    });
  }

  /**
   * Generate a long-lived Refresh Token (usually 7 days)
   * Used to get a new Access Token when the old one expires.
   */
  static generateRefreshToken(user) {
    const payload = {
      id: user.id,
      type: "refresh",
    };

    return jwt.sign(payload, config.jwt.refreshSecret, {
      expiresIn: config.jwt.refreshExpiration,
    });
  }

  /**
   * Verify an Access Token.
   * Throws error if invalid or expired.
   */
  static verifyAccessToken(token) {
    try {
      return jwt.verify(token, config.jwt.secret);
    } catch (_error) {
      throw new AppError("Invalid or expired access token", 401);
    }
  }

  /**
   * Verify a Refresh Token.
   * Throws error if invalid or expired.
   */
  static verifyRefreshToken(token) {
    try {
      return jwt.verify(token, config.jwt.refreshSecret);
    } catch (_error) {
      throw new AppError("Invalid or expired refresh token", 401);
    }
  }

  /**
   * Decode a token without verifying (useful for checking expiration on client side,
   * but server must always verify).
   */
  static decodeToken(token) {
    return jwt.decode(token);
  }

  /**
   * Invalidate a refresh token (Logout).
   * In a full production setup with Redis, you would add the token to a blacklist here.
   */
  static async blacklistToken(_token) {
    // Implementation: await redisClient.set(token, 'blacklisted', 'EX', 7 * 24 * 60 * 60);
    return true;
  }
}

export default JwtService;
