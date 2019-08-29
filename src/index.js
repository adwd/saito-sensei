import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
import * as firebase from 'firebase/app';
import 'firebase/auth';

const firebaseApp = firebase.initializeApp({
  apiKey: "AIzaSyCjJ5bHwwX-cNbJyjepIWfiIWeZ3rUBWOE",
  authDomain: "saito-sensei.firebaseapp.com",
  databaseURL: "https://saito-sensei.firebaseio.com",
  projectId: "saito-sensei",
});
const provider = new firebase.auth.GoogleAuthProvider();

const app = Elm.Main.init({
  node: document.getElementById('root')
});

firebase.auth().onAuthStateChanged(user => {
  console.log(user);
  if (user)  {
    app.ports.signedIn.send(true);
  }
});

app.ports.signIn.subscribe(() => {
  firebase.auth().signInWithPopup(provider)
    .then(res => {
      app.ports.signInSuccess.send(JSON.stringify(res, null, 2));
    })
    .catch(error => {
      app.ports.signInFailure.send(JSON.stringify(error, null, 2));
    });
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
