/** @type {import("@types/eslint").Linter.Config */

module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: "module",
  },
  plugins: ["prettier"],
  rules: {
    "no-unused-vars": [
      "error",
      {
        args: "after-used",
        argsIgnorePattern: "^_",
        varsIgnorePattern: "^_",
      },
    ],
    "no-var": "error",
    "prettier/prettier": "error",
  },
  extends: ["eslint:recommended", "prettier"],
};
