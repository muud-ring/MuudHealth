const { createRemoteJWKSet, jwtVerify } = require("jose");
const UserProfile = require("../models/UserProfile");

const region = process.env.AWS_REGION || "us-west-2";
const userPoolId = process.env.COGNITO_USER_POOL_ID;

if (!userPoolId) {
  console.warn("⚠️ COGNITO_USER_POOL_ID is missing in env");
}

const issuer = `https://cognito-idp.${region}.amazonaws.com/${userPoolId}`;
const JWKS = createRemoteJWKSet(new URL(`${issuer}/.well-known/jwks.json`));

function getBearerToken(req) {
  const auth = req.headers.authorization || "";
  const [type, token] = auth.split(" ");
  if (type !== "Bearer" || !token) return null;
  return token.trim();
}

async function requireAuth(req, res, next) {
  try {
    const token = getBearerToken(req);
    if (!token) {
      return res
        .status(401)
        .json({ message: "Missing Authorization Bearer token" });
    }

    const { payload } = await jwtVerify(token, JWKS, { issuer });

    const clientId = process.env.COGNITO_CLIENT_ID;
    const tokenClient = payload.client_id || payload.aud;

    if (clientId && tokenClient && tokenClient !== clientId) {
      return res.status(401).json({ message: "Token client mismatch" });
    }

    if (payload.token_use !== "access") {
      return res
        .status(401)
        .json({ message: "Please use access token for API calls" });
    }

    // ✅ Extract username correctly
    const usernameFromToken =
      payload["custom:username"] ||
      payload.preferred_username ||
      payload.username ||
      "";

    // ✅ Ensure profile exists AND hydrate username if missing
    await UserProfile.updateOne(
      { sub: payload.sub },
      {
        $setOnInsert: {
          sub: payload.sub,
          name: payload.name || "",
          bio: "",
          location: "",
          phone: "",
          avatarKey: "",
        },
        ...(usernameFromToken
          ? { $set: { username: usernameFromToken } }
          : {}),
      },
      { upsert: true }
    );

    req.user = {
      sub: payload.sub,
      username: usernameFromToken,
      scope: payload.scope,
      client_id: tokenClient,
      token_use: payload.token_use,
      claims: payload,
    };

    return next();
  } catch (err) {
    return res.status(401).json({
      message: "Unauthorized",
      code: err?.code || err?.name,
    });
  }
}

module.exports = requireAuth;
