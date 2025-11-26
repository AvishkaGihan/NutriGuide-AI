import express from "express";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Basic route to check if server is working
app.get("/", (req, res) => {
  res.send("NutriGuide AI Backend is Running (ES Modules)");
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
