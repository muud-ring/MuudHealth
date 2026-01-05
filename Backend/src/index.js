require("dotenv").config(); // MUST be first

const express = require("express");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");
const { createRemoteJWKSet, jwtVerify } = require("jose");

const connectDB = require("./config/db");

const onboardingRoute = require("./routes/onboardingRoute");
const debugRoute = require("./routes/debugRoute");
const cognitoAuthRoute = require("./routes/cognitoAuthRoute");
const userRoute = require("./routes/userRoute");
const peopleRoute = require("./routes/peopleRoute");
const chatRoute = require("./routes/chatRoute"); // ✅ ADD
const uploadRoute = require("./routes/uploadRoute");
const postRoute = require("./routes/postRoute");
const postReadRoute = require("./routes/postReadRoute");
const feedRoute = require("./routes/feedRoute");


const app = express();

app.use(cors());
app.use(express.json());

app.use("/auth", cognitoAuthRoute);
app.use("/debug", debugRoute);
app.use("/user", userRoute);
app.use("/onboarding", onboardingRoute);
app.use("/people", peopleRoute);
app.use("/chat", chatRoute); // ✅ ADD
app.use("/uploads", uploadRoute);
app.use("/posts", postRoute);
app.use("/posts", postReadRoute);
app.use("/feed", feedRoute);


app.get("/health", (req, res) => {
  res.json({ status: "ok", service: "MUUD Backend" });
});

const PORT = process.env.PORT || 4000;

// ✅ Create HTTP server + Socket.IO
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" },
});

// ✅ Cognito token verification setup (same as your requireAuth)
const region = process.env.AWS_REGION || "us-west-2";
const userPoolId = process.env.COGNITO_USER_POOL_ID;

if (!userPoolId) {
  console.warn("⚠️ COGNITO_USER_POOL_ID is missing in env");
}

const issuer = `https://cognito-idp.${region}.amazonaws.com/${userPoolId}`;
const JWKS = createRemoteJWKSet(new URL(`${issuer}/.well-known/jwks.json`));

// ✅ Socket auth (client passes access token)
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

io.on("connection", (socket) => {
  const sub = socket.user?.sub;

  if (sub) {
    socket.join(`user:${sub}`);
    console.log("🔌 socket connected sub:", sub);
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
    if (sub) console.log("🔌 socket disconnected sub:", sub);
  });
});

// ✅ Let controllers emit real-time events
app.set("io", io);

// ✅ Keep your DB connect flow
connectDB()
  .then(() => {
    server.listen(PORT, () => {
      console.log(`🚀 MUUD backend running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("❌ DB connection error:", err.message);
    process.exit(1);
  });
