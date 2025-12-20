const { createRemoteJWKSet, jwtVerify } = require("jose");

const region = process.env.AWS_REGION || "us-west-2";
const userPoolId = process.env.COGNITO_USER_POOL_ID;

if (!userPoolId) {
  console.warn("⚠️ COGNITO_USER_POOL_ID is missing in env");
}

const issuer = `https://cognito-idp.${region}.amazonaws.com/${userPoolId}`;
const jwksUrl = new URL(`${issuer}/.well-known/jwks.json`);
const JWKS = createRemoteJWKSet(jwksUrl);

// Extract "Bearer <token>"
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
      return res.status(401).json({ message: "Missing Authorization Bearer token" });
    }

    // Verify token signature + issuer + audience
    // Cognito access tokens typically have clientId as "aud" OR "client_id".
    // We'll validate issuer, and also validate the client_id/aud matches your app client.
    const { payload } = await jwtVerify(token, JWKS, {
      issuer,
    });

    const clientId = process.env.COGNITO_CLIENT_ID;
    const tokenClient = payload.client_id || payload.aud;

    if (clientId && tokenClient && tokenClient !== clientId) {
      return res.status(401).json({ message: "Token client mismatch" });
    }

    // Optional: ensure it’s an access token (recommended)
    if (payload.token_use && payload.token_use !== "access") {
      return res.status(401).json({ message: "Please use access token for API calls" });
    }

    // Attach user info to req
    req.user = {
      sub: payload.sub,
      username: payload.username,
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
