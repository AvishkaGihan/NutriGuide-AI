import express from "express";
import {
  register,
  login,
  refreshToken,
} from "../controllers/authController.js";

const router = express.Router();

// Public Routes
router.post("/register", register);
router.post("/login", login);
router.post("/refresh-token", refreshToken);

// Placeholder Routes (To be implemented in controller later)
router.post("/logout", (req, res) => {
  // Client-side logout usually involves deleting the token.
  // Server-side blacklist logic would go here.
  res.status(200).json({ success: true, message: "Logged out successfully" });
});

router.post("/password-reset", (req, res) => {
  res
    .status(501)
    .json({
      success: false,
      message: "Password reset flow pending implementation",
    });
});

export default router;
