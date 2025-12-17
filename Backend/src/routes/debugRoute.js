const express = require("express");
const router = express.Router();
const { STSClient, GetCallerIdentityCommand } = require("@aws-sdk/client-sts");

router.get("/whoami", async (req, res) => {
  try {
    const sts = new STSClient({ region: process.env.AWS_REGION || "us-west-2" });
    const out = await sts.send(new GetCallerIdentityCommand({}));
    res.json({
      account: out.Account,
      arn: out.Arn,
      userId: out.UserId,
      awsProfileEnv: process.env.AWS_PROFILE || null,
      awsRegionEnv: process.env.AWS_REGION || null,
    });
  } catch (e) {
    res.status(500).json({ message: e.message, code: e.name });
  }
});

module.exports = router;
