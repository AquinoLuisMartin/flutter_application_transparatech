import express from "express";
import apiRoutes from "./routes/api.js";

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Add CORS headers so Flutter Web / Emulators can communicate
app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  
  // Handle preflight OPTIONS request
  if (req.method === "OPTIONS") {
    return res.sendStatus(200);
  }
  
  next();
});

// Routes
app.get("/", (req, res) => {
  res.json({ message: "Server is running", status: "ok" });
});

app.use("/api", apiRoutes);

// Error handling middleware for JSON parsing syntax errors
app.use((err: any, req: any, res: any, next: any) => {
  if (err instanceof SyntaxError) {
    console.error("Malformed JSON received:", err.message);
    return res.status(400).json({ error: "Malformed JSON payload", details: err.message });
  }
  next(err);
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
