const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNotificationToNewUser = functions
  .region('asia-northeast1')
  .firestore.document('fcmTokens/{token}')
  .onCreate(async (snapshot, context) => {
    await admin.messaging().sendToDevice(context.params.token, {
      notification: {
        title: 'hello',
        body: 'hello notification',
        click_action: `https://${process.env.GCLOUD_PROJECT}.firebaseapp.com`,
      },
    });
  });
