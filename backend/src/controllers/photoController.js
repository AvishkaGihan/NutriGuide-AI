import PhotoModel from "../models/Photo.js";
import RecipeModel from "../models/Recipe.js";
import UserModel from "../models/User.js";
import GeminiService from "../services/geminiService.js";
import { asyncHandler, AppError } from "../utils/errorHandler.js";

/**
 * Analyze uploaded photo and generate recipes
 * POST /api/v1/photos/analyze
 */
export const analyzePhoto = asyncHandler(async (req, res, next) => {
  if (!req.file) {
    return next(new AppError("No image file provided", 400));
  }

  const userId = req.user.id;

  // 1. Analyze Image with Gemini Vision
  // req.file.buffer contains the image data in memory (thanks to multer)
  const ingredientsDetected = await GeminiService.analyzeImage(
    req.file.buffer,
    req.file.mimetype
  );

  if (!ingredientsDetected || ingredientsDetected.length === 0) {
    return next(
      new AppError("No ingredients detected. Please try a clearer photo.", 422)
    );
  }

  // 2. Save Photo Metadata (Log the scan)
  // In a real app, we upload req.file.buffer to S3 here and save the URL.
  // For MVP, we skip S3 storage and just log the event in DB.
  const photoLog = await PhotoModel.create({
    userId,
    s3Key: "temp-skipped-for-mvp",
    ingredientsDetected,
  });

  // 3. Generate Recipes based on these ingredients
  const userProfile = await UserModel.getFullProfile(userId);

  // Generate a primary recipe suggestion
  const recipe = await GeminiService.generateRecipe({
    userProfile,
    ingredients: ingredientsDetected,
    promptType: "based on these ingredients",
  });

  // 4. Save Generated Recipe
  const savedRecipe = await RecipeModel.create({
    ...recipe,
    user_id: userId,
  });

  res.status(200).json({
    success: true,
    data: {
      scanId: photoLog.id,
      ingredients: ingredientsDetected,
      suggestedRecipes: [savedRecipe], // Returning array to allow multiple later
    },
  });
});
