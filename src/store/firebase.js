const firebase = require("firebase");
require("firebase/firestore");

const firebaseApp = firebase.initializeApp({
  apiKey: 'AIzaSyDK2lBDUcFJ3lh9z5-ybxlHnxtU9rRGHN8',
  authDomain: 'pkb-app.firebaseapp.com',
  databaseURL: 'https://pkb-app.firebaseio.com',
  projectId: 'pkb-app',
  storageBucket: 'pkb-app.appspot.com',
  messagingSenderId: '1023467017138'
})

// firebase.firestore().enablePersistence()
//   .then(function() {
//       // Initialize Cloud Firestore through firebase
//       this.firestore = firebase.firestore();
//   })
//   .catch(function(err) {
//       if (err.code == 'failed-precondition') {
//           // Multiple tabs open, persistence can only be enabled
//           // in one tab at a a time.
//           // ...
//       } else if (err.code == 'unimplemented') {
//           // The current browser does not support all of the
//           // features required to enable persistence
//           // ...
//       }
//   });

export default {
  database: firebaseApp.database(),
  auth: firebaseApp.auth(),
  firestore: firebaseApp.firestore()
}
