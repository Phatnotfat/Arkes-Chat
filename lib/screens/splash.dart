import 'dart:async';
import 'package:arkes_chat_app/screens/chat.dart';
import 'package:arkes_chat_app/screens/complete_profile.dart';
import 'package:arkes_chat_app/screens/onboarding.dart';
import 'package:arkes_chat_app/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isWaiting = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isWaiting = false;
      });
    });
  }

  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 150,
          ), // Thay logo của bạn
          SizedBox(height: 20),
          Image.asset('assets/images/happy.png', width: 100),
        ],
      ),
    );
    if (!_isWaiting) {
      content = StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(snapshot.data!.uid)
                      .get(),
              builder: (ctx, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError ||
                    !userSnapshot.hasData ||
                    !userSnapshot.data!.exists) {
                  return const LoginScreen(); // Lỗi, quay lại login
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final isProfileComplete =
                    userData['isProfileComplete'] ?? false;

                return isProfileComplete
                    ? const ChatScreen()
                    : const CompleteProfileScreen();
              },
            );
          } else {
            return FutureBuilder<bool>(
              future: _hasSeenOnboarding(),
              builder: (ctx, onboardingSnapshot) {
                if (onboardingSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return onboardingSnapshot.data == true
                    ? const LoginScreen()
                    : const OnboardingScreen();
              },
            );
          }
        },
      );
    }
    return Scaffold(body: content);
  }
}
