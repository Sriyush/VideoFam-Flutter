import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:videofam/screens/Home.dart';
import 'package:videofam/screens/otpver.dart';
import 'package:videofam/screens/recvid.dart';
import 'package:videofam/screens/ss.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VideoFam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: AuthenticationWrapper(), // Use a wrapper to check user authentication
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is already authenticated, navigate to the home screen
      return ss(); // Replace with your home screen
    } else {
      // User is not authenticated, navigate to the login/signup screen
      return MyHomePage(title: 'VideoFam'); // Replace with your login/signup screen
    }
  }
}
