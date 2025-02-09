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
