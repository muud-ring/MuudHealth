// backend/src/server.js
//
// HTTP server, Socket.IO real-time layer, database bootstrap, and
// graceful shutdown.  Imports the Express app from app.js so that
// tests can use the app directly via supertest without booting a
// full server.

const http = require("http");
const { Server } = require("socket.io");
const { createRemoteJWKSet, jwtVerify } = require("jose");

const createApp = require("./app");
const connectDB = require("./config/db");
const { initFirebase } = require("./config/firebase");
const logger = require("./utils/logger");

// ── Build Express app ────────────────────────────────────────────
const app = createApp();
const corsOptions = app.get("corsOptions");

// ── HTTP server + Socket.IO ──────────────────────────────────────
const server = http.createServer(app);
const io = new Server(server, { cors: corsOptions });

// Expose Socket.IO to controllers via req.app.get("io")
app.set("io", io);

// ── Cognito JWKS for WebSocket auth ─────────────────────────────
const region = process.env.AWS_REGION || "us-west-2";
const userPoolId = process.env.COGNITO_USER_POOL_ID;

if (!userPoolId) {
  logger.warn("COGNITO_USER_POOL_ID is missing in env");
}

const issuer = `https://cognito-idp.${region}.amazonaws.com/${userPoolId}`;
const JWKS = createRemoteJWKSet(new URL(`${issuer}/.well-known/jwks.json`));

// ── Socket.IO auth middleware ────────────────────────────────────
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error("Missing token"));

    const { payload } = await jwtVerify(token, JWKS, { issuer });

    if (payload.token_use && payload.token_use !== "access") {
      return next(new Error("Please use access token"));
    }

    socket.user = { sub: payload.sub };
    return next();
  } catch (e) {
    return next(new Error("Unauthorized"));
  }
});

// ── Socket.IO connection handling ────────────────────────────────
io.on("connection", (socket) => {
  const sub = socket.user?.sub;

  if (sub) {
    socket.join(`user:${sub}`);
  }

  socket.on("joinConversation", (conversationId) => {
    if (!conversationId) return;
    socket.join(`conv:${conversationId}`);
  });

  socket.on("leaveConversation", (conversationId) => {
    if (!conversationId) return;
    socket.leave(`conv:${conversationId}`);
  });

  socket.on("disconnect", () => {
    // client disconnected
  });
});

// ── Graceful shutdown ────────────────────────────────────────────
let isShuttingDown = false;

async function gracefulShutdown(signal) {
  if (isShuttingDown) return;
  isShuttingDown = true;

  logger.info({ signal }, "Shutdown signal received — draining connections");

  // 1. Stop accepting new connections
  server.close(() => {
    logger.info("HTTP server closed");
  });

  // 2. Close Socket.IO connections
  io.close(() => {
    logger.info("Socket.IO server closed");
  });

  // 3. Close database connection
  try {
    const mongoose = require("mongoose");
    await mongoose.connection.close();
    logger.info("MongoDB connection closed");
  } catch (err) {
    logger.error({ err }, "Error closing MongoDB connection");
  }

  // 4. Exit after a timeout to allow drain
  const SHUTDOWN_TIMEOUT_MS = 10_000;
  setTimeout(() => {
    logger.warn("Forced shutdown after timeout");
    process.exit(1);
  }, SHUTDOWN_TIMEOUT_MS).unref();

  process.exit(0);
}

process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));

// ── Initialize Firebase ──────────────────────────────────────────
initFirebase();

// ── Boot: connect DB then start listening ────────────────────────
const PORT = process.env.PORT || 4000;

connectDB()
  .then(() => {
    server.listen(PORT, () => {
      logger.info({ port: PORT, env: process.env.NODE_ENV || "development" }, "MUUD Backend listening");
    });
  })
  .catch((err) => {
    logger.error({ err }, "DB connection error — aborting startup");
    process.exit(1);
  });

module.exports = { app, server, io };
