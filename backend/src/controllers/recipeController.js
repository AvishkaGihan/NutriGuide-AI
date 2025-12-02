import RecipeModel from "../models/Recipe.js";
import GeminiService from "../services/geminiService.js";
import UserModel from "../models/User.js";
import { asyncHandler, AppError } from "../utils/errorHandler.js";

/**
 * Get single recipe details
 * GET /api/v1/recipes/:id
 */
export const getRecipe = asyncHandler(async (req, res, next) => {
  const recipe = await RecipeModel.findById(req.params.id);

  if (!recipe) {
    return next(new AppError("Recipe not found", 404));
  }

  res.status(200).json({
    success: true,
    data: recipe,
  });
});

/**
 * Get recent recipes for current user
 * GET /api/v1/recipes
 */
export const getMyRecipes = asyncHandler(async (req, res) => {
  const recipes = await RecipeModel.findByUserId(req.user.id);

  res.status(200).json({
    success: true,
    data: recipes,
  });
});

/**
 * Generate a variation of an existing recipe
 * POST /api/v1/recipes/:id/variation
 */
export const generateVariation = asyncHandler(async (req, res, next) => {
  const { modificationRequest } = req.body; // e.g., "Make it vegetarian"
  const originalRecipeId = req.params.id;

  const originalRecipe = await RecipeModel.findById(originalRecipeId);
  if (!originalRecipe) {
    return next(new AppError("Original recipe not found", 404));
  }

  const userProfile = await UserModel.getFullProfile(req.user.id);

  // Use Gemini to adapt the recipe
  // We reuse the generateRecipe service but pass the context
  const prompt = `
    Take this recipe: "${originalRecipe.name}"
    Ingredients: ${JSON.stringify(originalRecipe.ingredients)}
    Modification: ${modificationRequest}
  `;

  const newRecipeData = await GeminiService.generateRecipe({
    userProfile,
    ingredients: null,
    promptType: prompt,
  });

  // Save the new variation - normalize nutrition_estimates to nutrition
  const savedVariation = await RecipeModel.create({
    ...newRecipeData,
    nutrition: newRecipeData.nutrition_estimates,
    user_id: req.user.id,
  });

  // Include full recipe data in response
  const fullRecipeData = {
    ...savedVariation,
    ingredients: newRecipeData.ingredients,
    instructions: newRecipeData.instructions,
    nutrition: newRecipeData.nutrition_estimates,
    prep_time_minutes: newRecipeData.prep_time_minutes,
    cook_time_minutes: newRecipeData.cook_time_minutes,
    dietary_tags: newRecipeData.dietary_tags,
    allergen_warnings: newRecipeData.allergen_warnings,
  };

  res.status(201).json({
    success: true,
    data: fullRecipeData,
  });
});
