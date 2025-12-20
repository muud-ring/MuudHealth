require("dotenv").config(); // MUST be first

const express = require("express");
const cors = require("cors");

const debugRoute = require("./routes/debugRoute");
const cognitoAuthRoute = require("./routes/cognitoAuthRoute");
const userRoute = require("./routes/userRoute");

const app = express();

app.use(cors());
app.use(express.json());

app.use("/auth", cognitoAuthRoute);
app.use("/debug", debugRoute);
app.use("/user", userRoute);

app.get("/health", (req, res) => {
  res.json({ status: "ok", service: "MUUD Backend" });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`🚀 MUUD backend running on port ${PORT}`));
