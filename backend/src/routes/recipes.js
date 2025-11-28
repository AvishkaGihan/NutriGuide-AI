import express from "express";
import {
  getRecipe,
  getMyRecipes,
  generateVariation,
} from "../controllers/recipeController.js";
import { protect } from "../middleware/auth.js";

const router = express.Router();

// All recipe routes require authentication
router.use(protect);

// Get all recipes for current user
router.get("/", getMyRecipes);

// Get specific recipe details
router.get("/:id", getRecipe);

// Generate a variation (e.g., "Make it vegan")
router.post("/:id/variation", generateVariation);

// Direct generation (Note: Primary generation happens via Chat/Photos, this is for direct calls if needed)
router.post("/generate", (req, res) => {
  res
    .status(501)
    .json({ message: "Use Chat or Photo endpoints for primary generation" });
});

export default router;
