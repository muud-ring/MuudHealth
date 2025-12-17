const cognito = require("../config/cognito");
const {
  SignUpCommand,
  ConfirmSignUpCommand,
  InitiateAuthCommand,
  ForgotPasswordCommand,
  ConfirmForgotPasswordCommand,
} = require("@aws-sdk/client-cognito-identity-provider");

function normalizeUsername(identifier) {
  // Cognito expects the same "Username" you used at signup.
  // If signup uses email/phone as username, keep it identical here.
  return (identifier || "").trim();
}

exports.signup = async (req, res) => {
  try {
    const { identifier, password, fullName, username, birthdate } = req.body;

    if (!identifier || !password || !fullName || !username || !birthdate) {
      return res.status(400).json({ message: "Missing required fields." });
    }

    // birthdate must be YYYY-MM-DD
    // identifier is email or phone (E.164 recommended for phone, e.g. +14155552671)
    const cmd = new SignUpCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: normalizeUsername(identifier),
      Password: password,
      UserAttributes: [
        { Name: "name", Value: fullName },
        { Name: "birthdate", Value: birthdate },
        { Name: "custom:username", Value: username },
        // Optional: If your pool needs explicit email/phone attributes, you can set them too:
        // If identifier includes "@", set email; if starts with "+", set phone_number
        ...(identifier.includes("@") ? [{ Name: "email", Value: identifier }] : []),
        ...(!identifier.includes("@") ? [{ Name: "phone_number", Value: identifier }] : []),
      ],
    });

    const out = await cognito.send(cmd);

    return res.status(200).json({
      message: "Signup success. OTP sent for verification.",
      userSub: out.UserSub,
      userConfirmed: out.UserConfirmed,
      next: "confirm-signup",
    });
  } catch (err) {
    const msg = err?.message || "Signup failed";
    return res.status(400).json({ message: msg, code: err?.name });
  }
};

exports.confirmSignup = async (req, res) => {
  try {
    const { identifier, code } = req.body;

    if (!identifier || !code) {
      return res.status(400).json({ message: "Missing identifier or code." });
    }

    const cmd = new ConfirmSignUpCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: normalizeUsername(identifier),
      ConfirmationCode: code,
    });

    await cognito.send(cmd);

    return res.status(200).json({
      message: "OTP verified. Account confirmed.",
      next: "login",
    });
  } catch (err) {
    const msg = err?.message || "Confirm signup failed";
    return res.status(400).json({ message: msg, code: err?.name });
  }
};

exports.login = async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({ message: "Missing identifier or password." });
    }

    const cmd = new InitiateAuthCommand({
      AuthFlow: "USER_PASSWORD_AUTH",
      ClientId: process.env.COGNITO_CLIENT_ID,
      AuthParameters: {
        USERNAME: normalizeUsername(identifier),
        PASSWORD: password,
      },
    });

    const out = await cognito.send(cmd);

    return res.status(200).json({
      message: "Login success",
      tokens: {
        idToken: out.AuthenticationResult?.IdToken,
        accessToken: out.AuthenticationResult?.AccessToken,
        refreshToken: out.AuthenticationResult?.RefreshToken,
        expiresIn: out.AuthenticationResult?.ExpiresIn,
        tokenType: out.AuthenticationResult?.TokenType,
      },
    });
  } catch (err) {
    const msg = err?.message || "Login failed";
    return res.status(401).json({ message: msg, code: err?.name });
  }
};

exports.forgotPassword = async (req, res) => {
  try {
    const { identifier } = req.body;

    if (!identifier) {
      return res.status(400).json({ message: "Missing identifier." });
    }

    const cmd = new ForgotPasswordCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: normalizeUsername(identifier),
    });

    await cognito.send(cmd);

    return res.status(200).json({
      message: "Reset code sent.",
      next: "confirm-forgot-password",
    });
  } catch (err) {
    const msg = err?.message || "Forgot password failed";
    return res.status(400).json({ message: msg, code: err?.name });
  }
};

exports.confirmForgotPassword = async (req, res) => {
  try {
    const { identifier, code, newPassword } = req.body;

    if (!identifier || !code || !newPassword) {
      return res.status(400).json({ message: "Missing identifier/code/newPassword." });
    }

    const cmd = new ConfirmForgotPasswordCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: normalizeUsername(identifier),
      ConfirmationCode: code,
      Password: newPassword,
    });

    await cognito.send(cmd);

    return res.status(200).json({
      message: "Password reset successful.",
      next: "login",
    });
  } catch (err) {
    const msg = err?.message || "Confirm forgot password failed";
    return res.status(400).json({ message: msg, code: err?.name });
  }
};
