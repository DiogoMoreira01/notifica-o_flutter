
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyCmeFBql_2A3MOCz3TLQZxyLzn3jsRghQ8",
    authDomain: "dev-meetups-57eb4.firebaseapp.com",
    projectId: "dev-meetups-57eb4",
    storageBucket: "dev-meetups-57eb4.appspot.com",
    messagingSenderId: "103873934791",
    appId: "1:103873934791:web:e1c49d8dd18048a1f295e2",
    measurementId: "G-71QLSZJVF2"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});