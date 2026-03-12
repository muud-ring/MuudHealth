require("dotenv").config();
const mongoose = require("mongoose");
const path = require("path");

async function main() {
  if (!process.env.MONGO_URI) {
    console.error("❌ Missing MONGO_URI in .env");
    process.exit(1);
  }

  console.log("⚠️ DEV ONLY: wiping user-related collections...");

  // ✅ Use same TLS CA file style as your db.js
  const caFile = path.join(process.cwd(), "global-bundle.pem");

  await mongoose.connect(process.env.MONGO_URI, {
    tls: true,
    tlsCAFile: caFile,
    retryWrites: false,
  });

  const db = mongoose.connection.db;

  // ✅ Collections to wipe (your People + Chat data)
  const collectionsToWipe = [
    "userprofiles",
    "connections",
    "friendrequests",
    "conversations",
    "messages",
  ];

  for (const name of collectionsToWipe) {
    const exists = await db.listCollections({ name }).hasNext();
    if (exists) {
      const result = await db.collection(name).deleteMany({});
      console.log(`✅ wiped: ${name} (${result.deletedCount} docs)`);
    } else {
      console.log(`ℹ️ skipped (not found): ${name}`);
    }
  }

  await mongoose.disconnect();
  console.log("✅ Done. DB reset complete.");
  process.exit(0);
}

main().catch((e) => {
  console.error("❌ wipe failed:", e);
  process.exit(1);
});
