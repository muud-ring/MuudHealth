const { CognitoIdentityProviderClient } = require("@aws-sdk/client-cognito-identity-provider");

const region = process.env.AWS_REGION || "us-west-2";

const cognito = new CognitoIdentityProviderClient({ region });

module.exports = cognito;
