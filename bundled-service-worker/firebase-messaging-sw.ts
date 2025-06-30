import { initializeApp } from "firebase/app";
import {
  experimentalSetDeliveryMetricsExportedToBigQueryEnabled,
  getMessaging,
  isSupported,
  onBackgroundMessage,
} from "firebase/messaging/sw";

declare var self: ServiceWorkerGlobalScope;

self.addEventListener("install", (event) => {
  console.log(self);
  console.log(event);
});

const firebaseConfig = {
  apiKey: "AIzaSyDDXQkW2q_Ar641bW_XjJOi7GyeMNKDq1U",
  authDomain: "han-pos-demo.firebaseapp.com",
  databaseURL:
    "https://han-pos-demo-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "han-pos-demo",
  storageBucket: "han-pos-demo.appspot.com",
  messagingSenderId: "648584474232",
  appId: "1:648584474232:web:4b0ad54e2f47f0b98d078d",
  measurementId: "G-84G46PF3E1",
};

const app = initializeApp(firebaseConfig);

isSupported().then((isSupported) => {
  if (isSupported) {
    const messaging = getMessaging(app);

    experimentalSetDeliveryMetricsExportedToBigQueryEnabled(messaging, true);

    onBackgroundMessage(messaging, ({ notification: notification }) => {
      const { title, body, image } = notification ?? {};

      if (!title) {
        return;
      }

      self.registration.showNotification(title, {
        body,
        icon: image || "/assets/icons/icon-72x72.png",
      });
    });
  }
});
