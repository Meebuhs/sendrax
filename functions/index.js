const functions = require('firebase-functions');
const Firestore = require('@google-cloud/firestore');

const admin = require('firebase-admin');
admin.initializeApp();

const PROJECTID = 'sendrax-3dacb';
const USERS_COLLECTION = 'users';
const ATTEMPTS_COLLECTION = 'attempts';
const firestore = new Firestore({
  projectId: PROJECTID,
  timestampsInSnapshots: true,
});

exports.countAttempts = functions.https.onCall((data, context) => {
  const userId = data.userId;
  return admin.firestore().collection(USERS_COLLECTION).doc(userId).collection(ATTEMPTS_COLLECTION)
      .get().then(snapshot => {
        return { count: snapshot.size };
      }).catch(err => {
        console.error(err);
        return { error: 'unable to access attempts', err };
      });
});
