# User Bot: Check Telegram User Reaction

This is a userbot implementation using GramJS to check if a specific user has reacted to a Telegram post.
It logs in as a Telegram user (not a bot) and fetches the message data—including reaction information if available.

## Configuration

Edit the `config.js` file to set:
- **apiId**: Your Telegram API ID (from [my.telegram.org](https://my.telegram.org)).
- **apiHash**: Your Telegram API hash.
- **phoneNumber**: Your phone number used for Telegram login.
- **targetUserId**: The user ID whose reaction you want to check.
- **messageLink**: A link to the target message (e.g., `https://t.me/TestingReact123/3`).
  Alternatively, you can specify `chatId` and `messageId` directly.
- **reaction**: The reaction emoji to check (if applicable).
- **stringSession**: (Optional) A previously saved session string.

## Installation

1. Install dependencies:
   ```bash
   npm install
   ```

## Running

Run the userbot:
   ```bash
   npm start
   ```
