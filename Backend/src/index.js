const express = require("express");
const cors = require("cors");
const debugRoute = require("./routes/debugRoute");

require("dotenv").config();
const cognitoAuthRoute = require("./routes/cognitoAuthRoute");

console.log("AWS_REGION:", process.env.AWS_REGION);
console.log("COGNITO_USER_POOL_ID:", process.env.COGNITO_USER_POOL_ID);
console.log("COGNITO_CLIENT_ID:", process.env.COGNITO_CLIENT_ID);

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use("/auth", cognitoAuthRoute);
app.use("/debug", debugRoute);

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", service: "MUUD Backend" });
});

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`🚀 MUUD backend running on port ${PORT}`);
});