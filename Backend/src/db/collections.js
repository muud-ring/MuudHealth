// backend/src/db/collections.js

function getCollections(db) {
    return {
      onboarding: db.collection("onboarding"),
    };
  }
  
  async function ensureIndexes(db) {
    const { onboarding } = getCollections(db);
  
    // One onboarding record per user sub
    await onboarding.createIndex({ sub: 1 }, { unique: true });
  
    // Useful for queries/cleanup
    await onboarding.createIndex({ completed: 1 });
    await onboarding.createIndex({ updatedAt: -1 });
  }
  
  module.exports = { getCollections, ensureIndexes };
  