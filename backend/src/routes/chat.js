import express from "express";
import { streamMessage, getHistory } from "../controllers/chatController.js";
import { protect } from "../middleware/auth.js";

const router = express.Router();

// All chat routes require authentication
router.use(protect);

// Get conversation history
router.get("/history", getHistory);

// Stream a new message (SSE)
// Client connects here to receive the recipe/response token by token
router.post("/messages/stream", streamMessage);

// Standard message endpoint (Non-streaming fallback if needed)
router.post("/messages", (req, res) => {
  res
    .status(501)
    .json({ message: "Use /messages/stream for this MVP version" });
});

export default router;
