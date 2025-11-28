import express from "express";
import {
  getProfile,
  updateProfile,
  deleteAccount,
  exportData,
} from "../controllers/userController.js";
import { protect } from "../middleware/auth.js";

const router = express.Router();

// All user routes require authentication
router.use(protect);

// Get and Update Profile
router.route("/profile").get(getProfile).put(updateProfile);

// GDPR Data Export
router.get("/export-data", exportData);

// Delete Account (Soft delete)
router.delete("/account", deleteAccount);

export default router;
