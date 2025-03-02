import 'package:arkes_chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/animals.png', width: 350),
            const SizedBox(height: 5),
            SizedBox(
              width: 280,
              child: Text(
                "It's easy talking to your friends with Ark",
                textAlign: TextAlign.start,
                style: GoogleFonts.itim(
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 280,
              child: Text(
                "Chat with your friends simply and easily with Arkes",
                textAlign: TextAlign.start,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 75),
            IconButton(
              onPressed: () => _completeOnboarding(context),
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary,
                size: 45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
