const { onDocumentCreated } = require("firebase-functions/v2/firestore"); // Specific import for Firestore triggers
const admin = require('firebase-admin');
const { getMessaging } = require("firebase-admin/messaging"); // Specific import for Messaging

admin.initializeApp();

// Use the v2 syntax with the specific import
exports.myFunction = onDocumentCreated('chat/{messageId}', (event) => {
  const snapshot = event.data; // Get the document snapshot from the event
  if (!snapshot) {
    console.log("No data associated with the event");
    return null; // Return null or a resolved promise for no-op cases
  }
  const data = snapshot.data(); // Get the data from the snapshot

  console.log(`New message from ${data.username}: ${data.text}`);

  // Ensure the function returns a promise
  return getMessaging().send({
    notification: {
      title: data.username,
      body: data.text,
    },
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK', // Ensure this matches client-side handling
    },
    topic: 'chat', // Send to the 'chat' topic
  }).then((response) => {
    console.log('Successfully sent message:', response);
    return response;
  }).catch((error) => {
    console.error('Error sending message:', error);
    // Decide how to handle the error, potentially re-throwing or returning a specific value
    // For deploy analysis, returning null might be sufficient if the error is transient
    return null;
  });
});