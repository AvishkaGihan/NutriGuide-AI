import {
  GoogleGenerativeAI,
  HarmCategory,
  HarmBlockThreshold,
} from "@google/generative-ai";
import { config } from "./env.js";

// Initialize the Google Gemini Client
const genAI = new GoogleGenerativeAI(config.gemini.apiKey);

// Default Safety Settings
// We set these to BLOCK_MEDIUM_AND_ABOVE to ensure safe nutrition advice
// and prevent generation of harmful or hate speech.
const safetySettings = [
  {
    category: HarmCategory.HARM_CATEGORY_HARASSMENT,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
];

/**
 * Get a specific Gemini Model instance.
 * * @param {string} modelName - The model version (default: gemini-1.5-flash)
 * @returns {import('@google/generative-ai').GenerativeModel}
 */
export const getGeminiModel = (modelName = "gemini-1.5-flash") => {
  return genAI.getGenerativeModel({
    model: modelName,
    safetySettings: safetySettings,
  });
};

/**
 * Get the vision-capable model (for Fridge Scan).
 * Usually the same model, but allows us to switch specific versions easily.
 */
export const getVisionModel = () => {
  // gemini-1.5-flash is highly efficient for image analysis
  return getGeminiModel("gemini-1.5-flash");
};

/**
 * Get the reasoning-capable model (for complex nutrition queries).
 */
export const getChatModel = () => {
  // gemini-1.5-pro has better reasoning capabilities for complex diet questions
  // Switching to 'flash' can save costs if 'pro' is too expensive
  return getGeminiModel("gemini-1.5-pro");
};

export default genAI;
