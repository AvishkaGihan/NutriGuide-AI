import PhotoModel from "../models/Photo.js";
import RecipeModel from "../models/Recipe.js";
import UserModel from "../models/User.js";
import GeminiService from "../services/geminiService.js";
import NutritionService from "../services/nutritionService.js";
import { asyncHandler, AppError } from "../utils/errorHandler.js";

/**
 * Validate recipe data to ensure it has real values
 */
function validateRecipeData(recipe) {
  const issues = [];

  // Check nutrition values
  if (
    !recipe.nutrition_estimates ||
    recipe.nutrition_estimates.calories === 0 ||
    recipe.nutrition_estimates.calories === undefined
  ) {
    issues.push("Missing or zero calories");
  }

  // Check ingredients
  if (!recipe.ingredients || recipe.ingredients.length === 0) {
    issues.push("No ingredients provided");
  }

  // Check instructions
  if (!recipe.instructions || recipe.instructions.length === 0) {
    issues.push("No instructions provided");
  }

  // Check cooking times
  if (!recipe.prep_time_minutes || recipe.prep_time_minutes === 0) {
    issues.push("Missing prep time");
  }
  if (!recipe.cook_time_minutes || recipe.cook_time_minutes === 0) {
    issues.push("Missing cook time");
  }

  // Check image URL
  if (!recipe.image_url) {
    issues.push("Missing image URL");
  }

  return issues;
}

/**
 * Enrich recipe data with missing values (only if not provided by Gemini)
 */
function enrichRecipeData(recipe, ingredients) {
  // If nutrition is missing or has zero values, generate fallback estimates
  if (
    !recipe.nutrition_estimates ||
    recipe.nutrition_estimates.calories === 0 ||
    recipe.nutrition_estimates.calories === undefined
  ) {
    const ingredientCount = ingredients.length;
    recipe.nutrition_estimates = {
      calories: Math.min(150 + ingredientCount * 40, 800),
      protein_g: Math.max(10, ingredientCount * 5),
      carbs_g: Math.max(20, ingredientCount * 4),
      fat_g: Math.max(5, ingredientCount * 2),
    };
  }

  // Ensure cooking times are set (only if missing/zero)
  if (!recipe.prep_time_minutes || recipe.prep_time_minutes === 0) {
    recipe.prep_time_minutes = 15;
  }
  if (!recipe.cook_time_minutes || recipe.cook_time_minutes === 0) {
    recipe.cook_time_minutes = 25;
  }

  // Ensure ingredients have all required fields
  if (recipe.ingredients && Array.isArray(recipe.ingredients)) {
    recipe.ingredients = recipe.ingredients.map((ing) => ({
      name: ing.name || "Unknown ingredient",
      quantity: ing.quantity || "1",
      unit: ing.unit || "unit",
    }));
  }

  // Ensure instructions are properly formatted
  if (recipe.instructions && Array.isArray(recipe.instructions)) {
    recipe.instructions = recipe.instructions.map((instr) =>
      typeof instr === "string" ? instr : String(instr)
    );
  }

  // Ensure dietary_tags exists
  if (!recipe.dietary_tags || !Array.isArray(recipe.dietary_tags)) {
    recipe.dietary_tags = [];
  }

  return recipe;
}

/**
 * Analyze uploaded photo and generate recipes
 * POST /api/v1/photos/analyze
 */
export const analyzePhoto = asyncHandler(async (req, res, next) => {
  if (!req.file) {
    return next(new AppError("No image file provided", 400));
  }

  const userId = req.user.id;

  // 1. Analyze Image with Gemini Vision to detect ingredients
  const ingredientsDetected = await GeminiService.analyzeImage(
    req.file.buffer,
    req.file.mimetype
  );

  if (!ingredientsDetected || ingredientsDetected.length === 0) {
    return next(
      new AppError("No ingredients detected. Please try a clearer photo.", 422)
    );
  }

  // 2. Save Photo Metadata
  const photoLog = await PhotoModel.create({
    userId,
    s3Key: `scan_${Date.now()}`, // Just a reference ID
    ingredientsDetected,
  });

  // 3. Generate Recipe with ingredients and Gemini-generated image URL
  const userProfile = await UserModel.getFullProfile(userId);

  const recipe = await GeminiService.generateRecipe({
    userProfile,
    ingredients: ingredientsDetected,
    promptType: "based on these ingredients",
  });

  // 4. Validate and enrich recipe data
  const validationIssues = validateRecipeData(recipe);
  if (validationIssues.length > 0 && process.env.NODE_ENV === "development") {
    console.log("Recipe validation issues:", validationIssues);
  }

  const enrichedRecipe = enrichRecipeData(recipe, ingredientsDetected);

  // 5. Check for allergens and add warnings
  const allergenWarnings = NutritionService.checkAllergens(
    enrichedRecipe,
    userProfile.allergies
  );
  enrichedRecipe.allergen_warnings = allergenWarnings;

  // 6. Save Generated Recipe
  const savedRecipe = await RecipeModel.create({
    ...enrichedRecipe,
    user_id: userId,
    image_url: enrichedRecipe.image_url, // Use Gemini-generated image URL
    nutrition: enrichedRecipe.nutrition_estimates,
  });

  res.status(200).json({
    success: true,
    data: {
      scanId: photoLog.id,
      ingredients: ingredientsDetected,
      suggestedRecipes: [
        {
          ...savedRecipe,
          ingredients: enrichedRecipe.ingredients,
          instructions: enrichedRecipe.instructions,
          nutrition: enrichedRecipe.nutrition_estimates,
          prep_time_minutes: enrichedRecipe.prep_time_minutes,
          cook_time_minutes: enrichedRecipe.cook_time_minutes,
          servings: enrichedRecipe.servings || 1,
          dietary_tags: enrichedRecipe.dietary_tags,
          allergen_warnings: allergenWarnings,
          image_url: enrichedRecipe.image_url,
        },
      ],
    },
  });
});
