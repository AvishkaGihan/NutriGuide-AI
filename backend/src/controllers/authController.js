import UserModel from "../models/User.js";
import JwtService from "../services/jwtService.js";
import { asyncHandler, AppError } from "../utils/errorHandler.js";
import { validateRegister, validateLogin } from "../utils/validators.js";

/**
 * Register a new user
 * POST /api/v1/auth/register
 */
export const register = asyncHandler(async (req, res, _next) => {
  // 1. Validate Input
  const validData = validateRegister(req.body);

  // 2. Create User (Password hashing happens in Model)
  const user = await UserModel.create({
    email: validData.email,
    password: validData.password,
  });

  // 3. Update Preferences if provided during signup
  if (validData.dietary_goals || validData.restrictions) {
    await UserModel.updatePreferences(user.id, {
      dietary_goals: validData.dietary_goals,
      restrictions: validData.restrictions,
      allergies: validData.allergies,
    });
  }

  // 4. Generate Tokens
  const accessToken = JwtService.generateAccessToken(user);
  const refreshToken = JwtService.generateRefreshToken(user);

  // 5. Send Response
  res.status(201).json({
    success: true,
    data: {
      user: { id: user.id, email: user.email },
      tokens: { accessToken, refreshToken },
    },
  });
});

/**
 * Login user
 * POST /api/v1/auth/login
 */
export const login = asyncHandler(async (req, res, next) => {
  const { email, password } = validateLogin(req.body);

  // 1. Check if user exists
  const user = await UserModel.findByEmail(email);
  if (!user) {
    return next(new AppError("Invalid email or password", 401));
  }

  // 2. Verify Password
  const isMatch = await UserModel.verifyPassword(password, user.password_hash);
  if (!isMatch) {
    return next(new AppError("Invalid email or password", 401));
  }

  // 3. Generate Tokens
  const accessToken = JwtService.generateAccessToken(user);
  const refreshToken = JwtService.generateRefreshToken(user);

  res.status(200).json({
    success: true,
    data: {
      user: { id: user.id, email: user.email },
      tokens: { accessToken, refreshToken },
    },
  });
});

/**
 * Refresh Access Token
 * POST /api/v1/auth/refresh
 */
export const refreshToken = asyncHandler(async (req, res, next) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return next(new AppError("Refresh Token is required", 400));
  }

  // Verify Refresh Token
  const decoded = JwtService.verifyRefreshToken(refreshToken);

  // Check if user still exists
  const user = await UserModel.findById(decoded.id);
  if (!user) {
    return next(
      new AppError("User belonging to this token no longer exists", 401)
    );
  }

  // Generate new Access Token
  const newAccessToken = JwtService.generateAccessToken(user);

  res.status(200).json({
    success: true,
    data: { accessToken: newAccessToken },
  });
});
