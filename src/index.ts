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
  flags: null,
});

firebase.auth().getRedirectResult()
  .then(cred => {
    console.log('redirect result', cred);
    if (cred.user) {
      cred.user.getIdToken()
        .then(idToken => {
          console.log('idToken', idToken);
          localStorage.setItem('SENSEI_FIERBASE_LOGIN_TOKEN', idToken);
        });
      app.ports.signInSuccess.send(JSON.stringify(cred.user, null, 2));
    }
  })
  .catch(error => {
    console.log('redirect error', error);
    app.ports.signInFailure.send(JSON.stringify(error, null, 2));
  });

const token = localStorage.getItem('SENSEI_FIERBASE_LOGIN_TOKEN');
if (token) {
  const authCredential = firebase.auth.GoogleAuthProvider.credential(token);
  firebase.auth().signInWithCredential(authCredential)
    .then(cred => {
      console.log('sign in with credentail succeeded', cred);
      app.ports.signInSuccess.send(JSON.stringify(cred.user, null, 2));
    })
    .catch(error => {
      console.error('sign in with credentail failed', error);
    });
}

firebase.auth().onAuthStateChanged(user => {
  console.log(user);
  if (user) {
    app.ports.signedIn.send(true);
  } else {
    app.ports.signedIn.send(false);
  }
});

app.ports.signIn.subscribe(() => {
  firebase.auth().signInWithRedirect(provider);
});
