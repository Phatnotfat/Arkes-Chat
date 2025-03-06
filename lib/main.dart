import 'package:arkes_chat_app/services/notification_serivce.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'package:arkes_chat_app/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService().requestPermission();
  await LocalNotificationService().init();
  runApp(ProviderScope(child: const App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationHandle();
  }

  void notificationHandle() {
    FirebaseMessaging.onMessage.listen((event) async {
      print(event.notification!.title);
      LocalNotificationService().showNotification(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(93, 179, 141, 1),
        ),
        scaffoldBackgroundColor: Colors.white,
        // textTheme: GoogleFonts(),
      ),
      home: SplashScreen(),
    );
  }
}
