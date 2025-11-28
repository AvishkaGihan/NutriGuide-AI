import express from "express";
import multer from "multer";
import { analyzePhoto } from "../controllers/photoController.js";
import { protect } from "../middleware/auth.js";

const router = express.Router();

// Configure Multer for memory storage
// We process the image in memory before sending to Gemini/S3
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // Limit to 5MB
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new Error("Not an image! Please upload an image."), false);
    }
  },
});

// All photo routes require authentication
router.use(protect);

// Upload and analyze a fridge photo
router.post("/analyze", upload.single("file"), analyzePhoto);

// Get scan history (Placeholder based on controller implementation status)
router.get("/history", (req, res) => {
  res
    .status(501)
    .json({ message: "Scan history endpoint pending implementation" });
});

// Delete a scan (Placeholder)
router.delete("/:id", (req, res) => {
  res
    .status(501)
    .json({ message: "Delete scan endpoint pending implementation" });
});

export default router;
