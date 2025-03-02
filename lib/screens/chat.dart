import 'package:arkes_chat_app/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Xóa toàn bộ stack và quay lại SplashScreen
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: _logout, // Gọi hàm đăng xuất
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: const Center(child: Text('Hello')),
    );
  }
}
