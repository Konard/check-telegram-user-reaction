#!/bin/bash
# This script updates/creates the user-bot files for check-telegram-user-reaction.
# It creates or updates:
#   - README.md (with instructions and markdown code blocks written as \``` which will be fixed),
#   - config.js (with configuration variables),
#   - index.js (an example GramJS userbot implementation),
#   - package.json (if not already present).
#
# After creating each file, sed is used to replace:
#   - the literal sequence "\```" with "```" (actual code block markers)
#   - the literal sequence "\\\`" with "\`" (actual inline code quotes)
#
# Make the script executable with: chmod +x init.sh
# Then run it with: ./init.sh

echo "Updating README.md..."
cat > README.md << 'EOF'
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
   \```bash
   npm install
   \```

## Running

Run the userbot:
   \```bash
   npm start
   \```
EOF

# Fix inner code blocks and inline quotes in README.md:
sed -i.bak 's#\\```#```#g' README.md && rm README.md.bak
sed -i.bak 's#\\\\\`#\`#g' README.md && rm README.md.bak

echo "Updating config.js..."
cat > config.js << 'EOF'
module.exports = {
  // Telegram API credentials (get these from https://my.telegram.org)
  apiId: YOUR_API_ID,         // e.g., 123456
  apiHash: 'YOUR_API_HASH',   // e.g., 'abcdef1234567890abcdef1234567890'
  phoneNumber: 'YOUR_PHONE_NUMBER',  // e.g., '+1234567890'
  
  // Configuration for checking user reaction.
  // Set the target user ID whose reaction you want to check.
  targetUserId: '1339837872',  // e.g., '1339837872'
  
  // Provide EITHER a message link OR the chatId/messageId directly.
  // If a message link is provided, it should be in the format:
  //   https://t.me/ChannelUsername/MessageID
  messageLink: 'https://t.me/TestingReact123/3',
  
  // Alternatively, specify:
  // chatId: 'CHAT_OR_CHANNEL_ID',  // e.g., '-1002350662996'
  // messageId: YOUR_MESSAGE_ID,      // e.g., 3
  
  // The reaction emoji to check (if applicable)
  reaction: '👍',
  
  // Optional: previously saved string session (leave empty if not available)
  stringSession: ''
};
EOF

sed -i.bak 's#\\```#```#g' config.js && rm config.js.bak
sed -i.bak 's#\\\\\`#\`#g' config.js && rm config.js.bak

echo "Updating index.js..."
cat > index.js << 'EOF'
const { TelegramClient } = require('telegram');
const { StringSession } = require('telegram/sessions');
const input = require('input');
const config = require('./config');

const stringSession = new StringSession(config.stringSession);

(async () => {
  console.log("Connecting as a user...");
  const client = new TelegramClient(stringSession, config.apiId, config.apiHash, { connectionRetries: 5 });
  await client.start({
    phoneNumber: async () => await input.text("Enter your phone number: "),
    password: async () => await input.text("Enter your password (if 2FA enabled): "),
    phoneCode: async () => await input.text("Enter the code you received: "),
    onError: (err) => console.log(err)
  });
  console.log("Connected as user!");
  console.log("Session:", client.session.save());
  
  // If messageLink is provided, parse it to get chatId and messageId.
  if (config.messageLink) {
    try {
      const url = new URL(config.messageLink);
      const parts = url.pathname.split('/').filter(part => part.length > 0);
      if (parts.length >= 2) {
        const username = parts[0].startsWith('@') ? parts[0] : '@' + parts[0];
        try {
          const entity = await client.getEntity(username);
          config.chatId = entity.id;
          config.messageId = Number(parts[1]);
          console.log("Parsed chat id:", config.chatId, "and message id:", config.messageId, "from messageLink", config.messageLink);
        } catch (err) {
          console.error("Error fetching entity for username", username, ":", err);
        }
      } else {
        console.error("Invalid messageLink format in config.messageLink");
      }
    } catch (err) {
      console.error("Error parsing messageLink:", err);
    }
  }
  
  if (!config.chatId || !config.messageId) {
    console.error("chatId or messageId not specified.");
    process.exit(1);
  }
  
  try {
    const messages = await client.getMessages(config.chatId, { ids: config.messageId });
    if (messages.length > 0) {
      const message = messages[0];
      console.log("Retrieved message:", message);
      if (message.reactions) {

        if (message.reactions && message.reactions.results) {
          message.reactions.results.forEach(reaction => {
            console.log(`Reaction: ${JSON.stringify(reaction)}`);

            // Adjust property names based on actual structure.
            console.log(`Emoji: ${reaction.emoji}, User ID: ${reaction.userId}`);
          });
        } else {
          console.log("No detailed reaction data available.");
        }

        // The structure of reactions may vary depending on API version.
        // Here we assume message.reactions.results is an array of objects with a userId property.
        const reacted = message.reactions.results && message.reactions.results.some(r => r.userId === Number(config.targetUserId));
        if (reacted) {
          console.log(`User with ID ${config.targetUserId} has reacted to the message.`);
        } else {
          console.log(`User with ID ${config.targetUserId} has NOT reacted to the message.`);
        }
      } else {
        console.log("No reaction data available for this message.");
      }
    } else {
      console.error("Message not found.");
    }
  } catch (err) {
    console.error("Error retrieving message:", err);
  }
  
  process.exit(0);
})();
EOF

sed -i.bak 's#\\```#```#g' index.js && rm index.js.bak
sed -i.bak 's#\\\\\`#\`#g' index.js && rm index.js.bak

echo "Updating package.json..."
cat > package.json << 'EOF'
{
  "name": "user-bot",
  "version": "1.0.0",
  "description": "A user-bot to check if a user has reacted to a Telegram post using GramJS.",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "telegram": "^2.26.16",
    "input": "^1.0.0"
  },
  "license": "Unlicense"
}
EOF

sed -i.bak 's#\\```#```#g' package.json && rm package.json.bak
sed -i.bak 's#\\\\\`#\`#g' package.json && rm package.json.bak

echo "User-bot files have been created/updated successfully."