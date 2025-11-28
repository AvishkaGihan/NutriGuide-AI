import UserModel from "../models/User.js";
import ChatMessageModel from "../models/ChatMessage.js";
import RecipeModel from "../models/Recipe.js";
import { asyncHandler, AppError } from "../utils/errorHandler.js";

/**
 * Get current user profile
 * GET /api/v1/user/profile
 */
export const getProfile = asyncHandler(async (req, res, next) => {
  const profile = await UserModel.getFullProfile(req.user.id);

  if (!profile) {
    return next(new AppError("User profile not found", 404));
  }

  res.status(200).json({
    success: true,
    data: profile,
  });
});

/**
 * Update dietary preferences
 * PUT /api/v1/user/profile
 */
export const updateProfile = asyncHandler(async (req, res, _next) => {
  // Fields allowed to be updated
  const {
    dietary_goals,
    restrictions,
    allergies,
    activity_level,
    age_range,
    gender,
  } = req.body;

  const updatedProfile = await UserModel.updatePreferences(req.user.id, {
    dietary_goals,
    restrictions,
    allergies,
    activity_level,
    age_range,
    gender,
  });

  res.status(200).json({
    success: true,
    data: updatedProfile,
  });
});

/**
 * GDPR Data Export
 * GET /api/v1/user/export
 */
export const exportData = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  // Gather data from all domains
  const [profile, chatHistory, recipes] = await Promise.all([
    UserModel.getFullProfile(userId),
    ChatMessageModel.findByUserId(userId, 1000), // Get all/most history
    RecipeModel.findByUserId(userId, 1000),
  ]);

  const exportPackage = {
    exportDate: new Date().toISOString(),
    user: profile,
    data: {
      chat_history: chatHistory,
      saved_recipes: recipes,
    },
  };

  res.status(200).json({
    success: true,
    data: exportPackage,
  });
});

/**
 * Delete Account (Soft Delete)
 * DELETE /api/v1/user
 */
export const deleteAccount = asyncHandler(async (req, res) => {
  await UserModel.softDelete(req.user.id);

  res.status(200).json({
    success: true,
    message: "Account scheduled for deletion. You have been logged out.",
  });
});
