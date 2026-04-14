const { body } = require("express-validator");

const upsert = [
  body("favoriteColor")
    .optional()
    .isString()
    .withMessage("favoriteColor must be a string"),
  body("focusGoal")
    .optional()
    .isString()
    .withMessage("focusGoal must be a string"),
  body("activities")
    .optional()
    .isArray()
    .withMessage("activities must be an array"),
  body("notificationsEnabled")
    .optional()
    .isBoolean()
    .withMessage("notificationsEnabled must be a boolean"),
  body("completed")
    .optional()
    .isBoolean()
    .withMessage("completed must be a boolean"),
];

module.exports = { upsert };
