#!/bin/bash
# This script updates/creates the repository files for check-telegram-user-reaction.
# It creates or updates:
#   - README.md (with instructions and markdown code blocks written as \``` which will be fixed),
#   - config.js (with configuration variables),
#   - index.js (an example Telegram bot implementation),
#   - package.json (if not already present).
#
# After creating each file, sed is used to replace:
#   - the literal sequence "\```" with "```" (actual code block markers)
#   - the literal sequence "\\\`" with "\`" (actual inline code quotes)
#
# Make the script executable with: chmod +x update_repo.sh
# Then run it with: ./update_repo.sh

echo "Updating README.md..."
cat > README.md << 'EOF'
# check-telegram-user-reaction

An example Telegram bot to check if a user has reacted to a message in a Telegram channel or group.
Due to current limitations in the Telegram Bot API regarding native reaction data,
this project uses an inline keyboard button to simulate a reaction.

## Configuration

Edit the \`config.js\` file to set your Telegram bot token and required parameters:

- **botToken**: Your Telegram bot token from BotFather.
- **targetUserId**: The user ID to check for a reaction. If left empty, the bot will try to resolve the user using the username.
- **targetUsername**: The username of the target user (default: \\\`@drakonard\\\`).
- **reaction**: The reaction emoji (e.g., \\\`👍\\\`).

You can specify the target message in one of two ways:

1. **By message link:**  
   Provide a link (e.g., \\\`https://t.me/TestingReact123/3\\\`) via the \`messageLink\` field.
   The bot will parse the public channel username and message ID, then use \`getChat\` to obtain the internal chat ID.
2. **Directly by IDs:**  
   Alternatively, set \`chatId\` (e.g., \\\`7615853056\\\`) and \`messageId\` directly in \`config.js\`.

## Installation

1. Install dependencies:
   \```bash
   npm install
   \```

## Running

Start the bot using Node.js:
   \```bash
   node index.js
   \```

## Commands

- **/sendmessage**  
  Sends a message with an inline reaction button to the configured chat and saves its message ID.
- **/check**  
  Checks whether the configured target user has reacted to the target message.
EOF

# Fix inner code blocks and inline quotes in README.md:
sed -i.bak 's#\\```#```#g' README.md && rm README.md.bak
sed -i.bak 's#\\`#`#g' README.md && rm README.md.bak
sed -i.bak 's#\\\\`#`#g' README.md && rm README.md.bak

echo "Updating config.js..."
cat > config.js << 'EOF'
module.exports = {
  // Replace with your Telegram bot token from BotFather.
  botToken: 'YOUR_BOT_TOKEN',

  // Configuration for checking user reaction.
  // Set the target user ID here if known; otherwise, leave it empty to resolve via targetUsername.
  // targetUserId: '',
  // Username of the target user (default: @drakonard).
  targetUsername: '@drakonard',

  // Provide EITHER a message link OR the chatId/messageId directly.
  // If a message link is provided, it should be in the format:
  //   https://t.me/ChannelUsername/MessageID
  // For example:
  messageLink: 'https://t.me/TestingReact123/3',

  // If you prefer to provide IDs directly, comment out the line above and uncomment the following:
  // chatId: 'CHAT_OR_CHANNEL_ID',   // e.g., '7615853056'
  // messageId: YOUR_MESSAGE_ID,       // e.g., 3

  // The reaction emoji to simulate.
  reaction: '👍'
};
EOF

sed -i.bak 's#\\```#```#g' config.js && rm config.js.bak
sed -i.bak 's#\\\\\`#\`#g' config.js && rm config.js.bak

echo "Updating index.js..."
cat > index.js << 'EOF'
const TelegramBot = require('node-telegram-bot-api');
const config = require('./config');

// Create a bot that uses polling.
const bot = new TelegramBot(config.botToken, { polling: true });

// Utility: Parse a Telegram message link.
// Returns an object { username, messageId } if valid; otherwise, null.
function parseMessageLink(link) {
  try {
    const parsedUrl = new URL(link);
    // Example pathname: /TestingReact123/3
    const parts = parsedUrl.pathname.split('/').filter(part => part.length > 0);
    if (parts.length >= 2) {
      let username = parts[0];
      // Prepend '@' if missing.
      if (!username.startsWith('@')) {
        username = '@' + username;
      }
      return { username, messageId: parts[1] };
    }
    return null;
  } catch (e) {
    return null;
  }
}

// Global object to store reaction data.
// Key: message_id, Value: Set of user IDs who have "reacted".
const reactions = {};

// If config.messageLink is provided, parse it and update config.chatId and config.messageId.
if (config.messageLink) {
  const linkData = parseMessageLink(config.messageLink);
  if (linkData) {
    // Get chat info using the public username.
    bot.getChat(linkData.username)
      .then(chat => {
        config.chatId = chat.id;
        config.messageId = Number(linkData.messageId);
        console.log('Parsed chat id:', config.chatId, 'and message id:', config.messageId, 'from link', config.messageLink);
      })
      .catch(err => {
        console.error('Error fetching chat data from username:', err.message);
      });
  } else {
    console.error('Invalid message link format in config.messageLink');
  }
}

// If targetUserId is not set, resolve it using targetUsername.
if (!config.targetUserId && config.targetUsername) {
  bot.getChat(config.targetUsername)
    .then(chat => {
      config.targetUserId = chat.id;
      console.log('Resolved target user', config.targetUsername, 'to ID:', config.targetUserId);
    })
    .catch(err => {
      console.error('Error resolving target username:', err.message);
    });
}

// Listen for callback queries from inline keyboard buttons.
bot.on('callback_query', (callbackQuery) => {
  const msg = callbackQuery.message;
  const userId = callbackQuery.from.id;
  const messageId = msg.message_id;
  
  if (callbackQuery.data === 'react') {
    if (!reactions[messageId]) {
      reactions[messageId] = new Set();
    }
    reactions[messageId].add(userId);
    bot.answerCallbackQuery(callbackQuery.id, { text: 'Reaction recorded!' });
    console.log(`User ${userId} reacted to message ${messageId}.`);
  }
});

// Command to check if a specific user reacted to the specified message.
bot.onText(/\/check/, (msg) => {
  const chatId = msg.chat.id;
  const targetUserId = Number(config.targetUserId);
  const targetMessageId = config.messageId;
  
  if (!targetMessageId) {
    bot.sendMessage(chatId, 'No target message specified.');
    return;
  }
  
  if (reactions[targetMessageId] && reactions[targetMessageId].has(targetUserId)) {
    bot.sendMessage(chatId, `User with ID ${targetUserId} has reacted to message ${targetMessageId}.`);
  } else {
    bot.sendMessage(chatId, `User with ID ${targetUserId} has not reacted to message ${targetMessageId}.`);
  }
});

// Command to send a message with an inline reaction button.
// This command sends a message to the configured chat/channel and saves its message ID in config.messageId.
bot.onText(/\/sendmessage/, (msg) => {
  const chatId = config.chatId;
  if (!chatId) {
    bot.sendMessage(msg.chat.id, 'No chatId configured. Please set either a messageLink or chatId in config.js.');
    return;
  }
  bot.sendMessage(chatId, 'React to this message:', {
    reply_markup: {
      inline_keyboard: [
        [
          {
            text: config.reaction,
            callback_data: 'react'
          }
        ]
      ]
    }
  })
    .then(sentMsg => {
      config.messageId = sentMsg.message_id;
      console.log('Message sent with ID:', sentMsg.message_id);
    })
    .catch(err => {
      console.error('Error sending message:', err.message);
    });
});

console.log('Bot is running...');
EOF

sed -i.bak 's#\\```#```#g' index.js && rm index.js.bak
sed -i.bak 's#\\\\\`#\`#g' index.js && rm index.js.bak

# Optionally create a package.json if one doesn't exist.
if [ ! -f package.json ]; then
  echo "Creating package.json..."
  cat > package.json << 'EOF'
{
  "name": "check-telegram-user-reaction",
  "version": "1.0.0",
  "description": "An example Telegram bot to check if a user has reacted to a message using inline keyboard simulation. Supports obtaining target message info via a message link and resolving a target user by username.",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "keywords": [
    "telegram",
    "bot",
    "reaction",
    "node-telegram-bot-api"
  ],
  "author": "",
  "license": "Unlicense",
  "dependencies": {
    "node-telegram-bot-api": "^0.61.0"
  }
}
EOF
  sed -i.bak 's#\\```#```#g' package.json && rm package.json.bak
  sed -i.bak 's#\\\\\`#\`#g' package.json && rm package.json.bak
fi

echo "Repository files have been updated successfully."