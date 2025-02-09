# check-telegram-user-reaction

An example Telegram bot to check if a user has reacted to a message in a Telegram channel or group.
Due to current limitations in the Telegram Bot API regarding native reaction data,
this project uses an inline keyboard button to simulate a reaction.

## Configuration

Edit the `config.js` file to set your Telegram bot token and required parameters:

- **botToken**: Your Telegram bot token from BotFather.
- **targetUserId**: The user ID to check for a reaction. If left empty, the bot will try to resolve the user using the username.
- **targetUsername**: The username of the target user (default: `@drakonard`).
- **reaction**: The reaction emoji (e.g., `👍`).

You can specify the target message in one of two ways:

1. **By message link:**  
   Provide a link (e.g., `https://t.me/TestingReact123/3`) via the `messageLink` field.
   The bot will parse the public channel username and message ID, then use `getChat` to obtain the internal chat ID.
2. **Directly by IDs:**  
   Alternatively, set `chatId` (e.g., `7615853056`) and `messageId` directly in `config.js`.

## Installation

1. Install dependencies:
   ```bash
   npm install
   ```

## Running

Start the bot using Node.js:
   ```bash
   node index.js
   ```

## Commands

- **/sendmessage**  
  Sends a message with an inline reaction button to the configured chat and saves its message ID.
- **/check**  
  Checks whether the configured target user has reacted to the target message.
