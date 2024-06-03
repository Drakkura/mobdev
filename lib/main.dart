import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_sahabat_mahasiswa/view/dashboard.dart';
import 'package:login_sahabat_mahasiswa/view/login.view.dart';
import 'firebase_options.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_sahabat_mahasiswa/view/splash.view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return Future.value(true);
  });
}

String? globalFcmToken;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Workmanager().initialize(
      callbackDispatcher, // The top-level function, aka callbackDispatcher
      isInDebugMode: true // features to debug background tasks
      );

  Workmanager().registerPeriodicTask(
    "2",
    "checkTasks",
    frequency: Duration(minutes: 15), // defines the frequency of task execution
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  globalFcmToken = token;
  print("FCM Token: $token");

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashView(), // Start with the SplashView
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data != null) {
            return Dashboard();
          }
          return LoginView();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
