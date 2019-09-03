import './main.css';
import * as firebase from 'firebase/app';
import { Elm } from './Main';
import 'firebase/auth';
import 'firebase/firestore';
import 'firebase/messaging';

const firebaseApp = firebase.initializeApp({
  apiKey: 'AIzaSyCjJ5bHwwX-cNbJyjepIWfiIWeZ3rUBWOE',
  authDomain: 'saito-sensei.firebaseapp.com',
  databaseURL: 'https://saito-sensei.firebaseio.com',
  projectId: 'saito-sensei',
  storageBucket: 'saito-sensei.appspot.com',
  messagingSenderId: '953378465391',
  appId: '1:953378465391:web:08deb336cf8adb76',
});

// use one-tap sign in
// https://github.com/firebase/firebase-js-sdk/issues/455
// https://stackoverflow.com/questions/50258766/firebase-authentication-with-google-identity-googleyolo
// after sign in succeeded, store id token to localstroage
// use it to signInWithCredential

const provider = new firebase.auth.GoogleAuthProvider();

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: {
    pushPermission: Notification.permission,
    // NOTE: firebase auth status can be passed through flags?
  },
});

firebase
  .auth()
  .getRedirectResult()
  .then(cred => {
    console.log('redirect result', cred);
    if (cred.user) {
      app.ports.signedIn.send(cred.user);
    }
  })
  .catch(error => {
    console.log('redirect error', error);
  });

firebase.auth().onAuthStateChanged(user => {
  console.log(user);
  if (user) {
    app.ports.signedIn.send(user);
  }
});

app.ports.signIn.subscribe(() => {
  firebase.auth().signInWithRedirect(provider);
});

if ('serviceWorker' in navigator) {
  navigator.serviceWorker
    .register('/firebase-messaging-sw.js')
    .then(registration => {
      // Registration was successful
      console.log(
        'ServiceWorker registration successful with scope: ',
        registration,
      );
    })
    .catch(err => {
      // registration failed :(
      console.log('ServiceWorker registration failed: ', err);
    });
}

app.ports.requestPushNotification.subscribe(() => {
  Notification.requestPermission().then(permission => {
    app.ports.pushNotificationPermissionChange.send(permission);
    firebaseApp
      .messaging()
      .getToken()
      .then(token => {
        if (token) {
          firebaseApp
            .firestore()
            .collection('fcmTokens')
            .doc(token)
            .set({
              uid: firebase.auth().currentUser!.uid,
            })
            .then(console.log)
            .catch(console.error);
        }
      });
  });
});
