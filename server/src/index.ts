import express from "express";
import cors from "cors";
import helmet from "helmet";
import ngrok from "@ngrok/ngrok";
import { config } from "./config.js";
import apiRoutes from "./routes/api.js";

const app = express();

// ── H-3: Security headers ──
app.use(helmet());

// ── H-2: CORS — explicit allowlist, not wildcard ──
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, curl, Postman)
      if (!origin) {
        callback(null, true);
        return;
      }

      if (config.corsOrigins.includes(origin)) {
        callback(null, true);
        return;
      }

      // In development, automatically allow any localhost/127.0.0.1 port to facilitate Flutter web debugging
      if (!config.isProduction) {
        const isLocal = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
        if (isLocal) {
          callback(null, true);
          return;
        }
      }

      console.warn(`CORS Blocked: Origin '${origin}' is not allowed by CORS_ORIGINS config.`);
      callback(new Error(`Not allowed by CORS: Origin '${origin}' is not in the allowlist`));
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);

// ── M-2: Explicit body size limit ──
app.use(express.json({ limit: "16kb" }));

// Routes
app.get("/", (req, res) => {
  res.json({ message: "Server is running", status: "ok" });
});

app.use("/api", apiRoutes);

// ── H-4: Sanitized error handler — no internal details in production ──
app.use((err: any, req: any, res: any, next: any) => {
  if (err instanceof SyntaxError || err.status === 400) {
    console.warn(`Client request error (400 Bad Request): ${err.message}`);
    return res.status(400).json({ error: "Malformed request body" });
  }

  // CORS rejection
  if (err.message && err.message.includes("Not allowed by CORS")) {
    return res.status(403).json({ error: "Origin not allowed" });
  }

  console.error("Unhandled error:", err);
  res.status(500).json({
    error: "Internal server error",
    ...(config.isProduction ? {} : { details: err.message }),
  });
});

// Store ngrok listener globally to prevent garbage collection from closing the tunnel
let activeNgrokListener: any = null;

// Start server
app.listen(config.port, async () => {
  console.log(`Server is running on http://localhost:${config.port}`);

  // Automatically start ngrok tunnel in development if NGROK_AUTHTOKEN is set
  if (!config.isProduction) {
    const authtoken = process.env.NGROK_AUTHTOKEN;
    if (authtoken) {
      try {
        console.log("Starting ngrok tunnel...");
        activeNgrokListener = await ngrok.forward({
          addr: config.port,
          authtoken: authtoken,
        });
        console.log(`🚀 ngrok tunnel established at: ${activeNgrokListener.url()}`);
        console.log(`👉 Put this URL as the tunnelUrl in client/lib/core/network/http_client.dart`);
      } catch (err: any) {
        console.error("Failed to start ngrok tunnel:", err.message || err);
      }
    } else {
      console.log("💡 Tip: To start ngrok automatically with the server, add NGROK_AUTHTOKEN to your server/.env file.");
    }
  }
});
