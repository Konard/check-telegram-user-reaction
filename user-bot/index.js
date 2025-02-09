const { Api, TelegramClient } = require('telegram');
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
            console.log(`Emoji: ${reaction.reaction.emoticon}, User ID: ${reaction.reaction.userId}`);
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
  
  // Now, invoke the low-level method to get the detailed reaction list.
  try {
    // Get an InputPeer from the chatId.
    const inputPeer = await client.getInputEntity(config.chatId);
    // Invoke the method using the proper constructor name (note the lowercase 'g').
    
    // const reactionList = await client.invoke(new Api.messages.GetMessageReactionsList({
    //   // _: 'messages.getMessageReactionsList',
    //   peer: inputPeer,
    //   id: config.messageId,
    //   reaction: config.reaction, // Specify the reaction emoji you want (or omit to get all reactions)
    //   offset: "",  // For pagination, an empty string means starting from the beginning.
    //   limit: 100,  // Adjust the limit as needed.
    // }));

    // const reactionList = await client.call({
    //   _: 'messages.getMessageReactionsList',
    //   peer: inputPeer,
    //   id: config.messageId,
    //   // reaction: config.reaction, // Specify the reaction emoji you want (or omit to get all reactions)
    //   offset: "",  // For pagination, an empty string means starting from the beginning.
    //   limit: 100,  // Adjust the limit as needed.
    // });

    console.log("Detailed reaction list:", reactionList);
    if (reactionList && reactionList.users) {
      reactionList.users.forEach(user => {
        console.log(`User: ${user.firstName} (ID: ${user.id}) reacted.`);
      });
    } else {
      console.log("No detailed reaction user data available.");
    }
  } catch (err) {
    console.error("Error fetching detailed reaction list:", err);
  }

  process.exit(0);
})();
