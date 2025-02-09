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
