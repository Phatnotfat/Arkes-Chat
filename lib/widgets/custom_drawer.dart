import 'package:arkes_chat_app/screens/add_friend.dart';
import 'package:arkes_chat_app/screens/friend_requests.dart';
import 'package:arkes_chat_app/screens/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    super.key,
    required this.email,
    required this.imageUrl,
    required this.username,
  });
  final String username;
  final String imageUrl;
  final String email;
  @override
  State<CustomDrawer> createState() {
    return _CustomDrawerScreen();
  }
}

class _CustomDrawerScreen extends State<CustomDrawer> {
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
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.username,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(widget.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(widget.imageUrl),
              radius: 40,
            ),
            decoration: BoxDecoration(color: Colors.green[300]),
          ),

          ListTile(
            leading: Icon(Icons.archive_outlined),
            title: Text("Archive Chats"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/archive");
            },
          ),
          ListTile(
            leading: Icon(Icons.people_alt),
            title: Text("Friends"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => AddFriendScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add_alt_1_outlined),
            title: Text("Add Friends"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => AddFriendScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people_outline_sharp),
            title: Text("Friend Requests"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => RequestFriendScreen()),
              );
            },
          ),

          Divider(), // Đường gạch ngang ngăn cách
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: _logout, // Gọi hàm đăng xuất
          ),
        ],
      ),
    );
  }
}
