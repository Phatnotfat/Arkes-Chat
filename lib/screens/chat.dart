import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/user-avatar.png'),
            radius: 60,
          ),
          title: const Text('Trần Tiến Phát'),
          subtitle: const Text('Active now'),
        ),
      ),
    );
  }
}
