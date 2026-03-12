const mongoose = require("mongoose");
const path = require("path");

async function connectDB() {
  try {
    const uri = process.env.MONGO_URI;
    if (!uri) throw new Error("MONGO_URI is missing in .env");

    const caFile = path.join(process.cwd(), "global-bundle.pem");

    // 1️⃣ Connect to DocumentDB first
    await mongoose.connect(uri, {
      tls: true,
      tlsCAFile: caFile,
      retryWrites: false,
    });

    console.log("✅ DocumentDB connected");

    // 2️⃣ Get native MongoDB db object from mongoose
    const db = mongoose.connection.db;

    // 3️⃣ Create indexes AFTER connection
    const { ensureIndexes } = require("../db/collections");
    await ensureIndexes(db);

    console.log("✅ DB indexes ensured");
  } catch (err) {
    console.error("❌ DB connection error:", err.message);
    process.exit(1);
  }
}

module.exports = connectDB;
