import jwt from "jsonwebtoken";
import { config } from "../config/env.js";
import { AppError } from "../utils/errorHandler.js";

/**
 * Middleware to protect routes ensuring a valid JWT is present.
 */
export const protect = async (req, res, next) => {
  let token;

  // 1. Check for token in Authorization header (Bearer <token>)
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    return next(
      new AppError("Not authorized to access this route. Please login.", 401)
    );
  }

  try {
    // 2. Verify token
    const decoded = jwt.verify(token, config.jwt.secret);

    // 3. Attach user info to request object
    // The payload usually contains { id, email, iat, exp }
    req.user = {
      id: decoded.id || decoded.sub, // Handle 'sub' standard claim or custom 'id'
      email: decoded.email,
    };

    next();
  } catch (error) {
    // Handle specific JWT errors
    if (error.name === "TokenExpiredError") {
      return next(new AppError("Session expired. Please login again.", 401));
    }
    if (error.name === "JsonWebTokenError") {
      return next(new AppError("Invalid token. Authorization failed.", 401));
    }
    return next(new AppError("Not authorized.", 401));
  }
};

/**
 * Optional: Middleware to restrict access to specific roles (e.g., admin)
 * Usage: router.delete('/users/:id', protect, restrictTo('admin'), deleteUser);
 */
export const restrictTo = (...roles) => {
  return (req, res, next) => {
    // Assuming req.user.role exists (would need to be added to JWT payload or fetched from DB)
    if (!roles.includes(req.user.role)) {
      return next(
        new AppError("You do not have permission to perform this action", 403)
      );
    }
    next();
  };
};
