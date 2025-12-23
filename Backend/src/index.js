require("dotenv").config(); // MUST be first

const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");

const onboardingRoute = require("./routes/onboardingRoute");
const debugRoute = require("./routes/debugRoute");
const cognitoAuthRoute = require("./routes/cognitoAuthRoute");
const userRoute = require("./routes/userRoute");
const peopleRoute = require("./routes/peopleRoute"); // ✅ correct

const app = express();

app.use(cors());
app.use(express.json());

app.use("/auth", cognitoAuthRoute);
app.use("/debug", debugRoute);
app.use("/user", userRoute);
app.use("/onboarding", onboardingRoute);
app.use("/people", peopleRoute); // ✅ correct

app.get("/health", (req, res) => {
  res.json({ status: "ok", service: "MUUD Backend" });
});

const PORT = process.env.PORT || 4000;

connectDB()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`🚀 MUUD backend running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("❌ DB connection error:", err.message);
    process.exit(1);
  });
