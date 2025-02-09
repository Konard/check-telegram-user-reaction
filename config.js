module.exports = {
  // Replace with your Telegram bot token from BotFather.
  botToken: 'YOUR_BOT_TOKEN',

  // Configuration for checking user reaction.
  // Set the target user ID here if known; otherwise, leave it empty to resolve via targetUsername.
  targetUserId: '1339837872',
  // Username of the target user (default: @drakonard).
  // targetUsername: '@drakonard',

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
