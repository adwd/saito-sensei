import './main.css';
import { Elm } from './Main';
import * as firebase from 'firebase/app';
import 'firebase/auth';

const firebaseApp = firebase.initializeApp({
  apiKey: "AIzaSyCjJ5bHwwX-cNbJyjepIWfiIWeZ3rUBWOE",
  authDomain: "saito-sensei.firebaseapp.com",
  databaseURL: "https://saito-sensei.firebaseio.com",
  projectId: "saito-sensei",
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

firebase.auth().getRedirectResult()
  .then(cred => {
    console.log('redirect result', cred);
    if (cred.user) {
      app.ports.signInSuccess.send(JSON.stringify(cred.user, null, 2));
    }
  })
  .catch(error => {
    console.log('redirect error', error);
    app.ports.signInFailure.send(JSON.stringify(error, null, 2));
  });

firebase.auth().onAuthStateChanged(user => {
  console.log(user);
  if (user) {
    app.ports.signedIn.send(true);
    app.ports.signInSuccess.send(JSON.stringify(user.email, null, 2));
  } else {
    app.ports.signedIn.send(false);
  }
});

app.ports.signIn.subscribe(() => {
  firebase.auth().signInWithRedirect(provider);
});

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js')
    .then(registration => {
      // Registration was successful
      console.log('ServiceWorker registration successful with scope: ', registration);
    }).catch(err => {
      // registration failed :(
      console.log('ServiceWorker registration failed: ', err);
    });
}

app.ports.requestPushNotification.subscribe(() => {
  Notification.requestPermission().then(permission => {
    app.ports.pushNotificationPermissionChange.send(permission);
  })
})