// backend/src/app.js
//
// Express application factory — exports the configured app for both
// the production server (server.js) and test harnesses (supertest).

require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const { apiLimiter } = require("./middleware/rateLimiter");
const errorHandler = require("./middleware/errorHandler");
const requestLogger = require("./middleware/requestLogger");
const { phiLoggingMiddleware } = require("./middleware/phiMasking");
const { enforceResidency } = require("./config/dataResidency");
const { metricsMiddleware } = require("./services/monitoringService");
const { featureFlagMiddleware } = require("./services/featureFlagService");
const monitoring = require("./services/monitoringService");

// ── Route imports ────────────────────────────────────────────────
const onboardingRoute = require("./routes/onboardingRoute");
const debugRoute = require("./routes/debugRoute");
const cognitoAuthRoute = require("./routes/cognitoAuthRoute");
const userRoute = require("./routes/userRoute");
const peopleRoute = require("./routes/peopleRoute");
const chatRoute = require("./routes/chatRoute");
const uploadRoute = require("./routes/uploadRoute");
const postRoute = require("./routes/postRoute");
const postReadRoute = require("./routes/postReadRoute");
const feedRoute = require("./routes/feedRoute");
const vaultRoute = require("./routes/vaultRoute");
const biometricsRoute = require("./routes/biometricsRoute");
const notificationRoute = require("./routes/notificationRoute");
const adminDevRoute = require("./routes/adminDevRoute");
const complianceRoute = require("./routes/complianceRoute");
const accountRoute = require("./routes/accountRoute");
const organizationRoute = require("./routes/organizationRoute");
const sharedVaultRoute = require("./routes/sharedVaultRoute");
const servicePlanRoute = require("./routes/servicePlanRoute");
const signalLoopRoute = require("./routes/signalLoopRoute");

// ── App factory ──────────────────────────────────────────────────
function createApp() {
  const app = express();

  // ── CORS ─────────────────────────────────────────────────────
  const allowedOrigins = (process.env.ALLOWED_ORIGINS || "http://localhost:3000")
    .split(",")
    .map((s) => s.trim());

  const corsOptions = {
    origin: function (origin, callback) {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
    credentials: true,
  };

  app.set("corsOptions", corsOptions); // expose for Socket.IO in server.js

  // ── Global middleware ────────────────────────────────────────
  app.use(helmet());
  app.use(cors(corsOptions));
  app.use(express.json());
  app.use(apiLimiter);
  app.use(requestLogger);
  app.use(metricsMiddleware);
  app.use(enforceResidency);
  app.use(phiLoggingMiddleware);
  app.use(featureFlagMiddleware);

  // ── Health check (root level — no version prefix) ───────────
  app.get("/health", async (_req, res) => {
    try {
      const report = await monitoring.getHealthReport();
      res.json({ status: "ok", service: "MUUD Backend", version: "1.1", ...report });
    } catch {
      res.json({ status: "ok", service: "MUUD Backend", version: "1.1" });
    }
  });

  // ── Auth routes (root level for backward compatibility) ─────
  app.use("/auth", cognitoAuthRoute);

  // ── API v1 routes ───────────────────────────────────────────
  const v1 = express.Router();

  v1.use("/debug", debugRoute);
  v1.use("/user", userRoute);
  v1.use("/onboarding", onboardingRoute);
  v1.use("/people", peopleRoute);
  v1.use("/chat", chatRoute);
  v1.use("/uploads", uploadRoute);
  v1.use("/posts", postRoute);
  v1.use("/posts", postReadRoute);
  v1.use("/feed", feedRoute);
  v1.use("/vault", vaultRoute);
  v1.use("/biometrics", biometricsRoute);
  v1.use("/notifications", notificationRoute);
  v1.use("/compliance", complianceRoute);
  v1.use("/account", accountRoute);
  v1.use("/organizations", organizationRoute);
  v1.use("/shared-vault", sharedVaultRoute);
  v1.use("/service-plans", servicePlanRoute);
  v1.use("/signals", signalLoopRoute);

  app.use("/api/v1", v1);

  // ── Backward-compatible unversioned routes (deprecation shim)
  // TODO: Remove after all clients migrate to /api/v1
  app.use("/debug", debugRoute);
  app.use("/user", userRoute);
  app.use("/onboarding", onboardingRoute);
  app.use("/people", peopleRoute);
  app.use("/chat", chatRoute);
  app.use("/uploads", uploadRoute);
  app.use("/posts", postRoute);
  app.use("/posts", postReadRoute);
  app.use("/feed", feedRoute);
  app.use("/vault", vaultRoute);
  app.use("/biometrics", biometricsRoute);
  app.use("/notifications", notificationRoute);

  // ── DEV-only admin routes (never exposed in production) ─────
  if (process.env.NODE_ENV !== "production") {
    app.use("/dev", adminDevRoute);
  }

  // ── Global error handler (must be after all routes) ─────────
  app.use(errorHandler);

  return app;
}

module.exports = createApp;
