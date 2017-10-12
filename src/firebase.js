import Firebase from 'firebase'

const firebaseApp = Firebase.initializeApp({
  apiKey: 'AIzaSyDK2lBDUcFJ3lh9z5-ybxlHnxtU9rRGHN8',
  authDomain: 'pkb-app.firebaseapp.com',
  databaseURL: 'https://pkb-app.firebaseio.com',
  projectId: 'pkb-app',
  storageBucket: 'pkb-app.appspot.com',
  messagingSenderId: '1023467017138'
})

// Export the database for components to use.
// If you want to get fancy, use mixins or provide / inject to avoid redundant imports.
export const db = firebaseApp.database()
