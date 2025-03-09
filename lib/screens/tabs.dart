import 'package:arkes_chat_app/screens/add_message.dart';
import 'package:arkes_chat_app/screens/archive.dart';
import 'package:arkes_chat_app/screens/chats.dart';
import 'package:arkes_chat_app/screens/splash.dart';
import 'package:arkes_chat_app/screens/story.dart';
import 'package:arkes_chat_app/widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  String _username = "Loading...";
  String _imageUrl = "";
  String _email = '';
  User? user;
  var _indexTab = 0;
  Future<void> _fetchUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user!.uid;

      // Lấy dữ liệu từ Firestore
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _username = data['username'] ?? "No Name";
          print(data['image_url']);
          _imageUrl =
              data['image_url'] ??
              "https://www.w3schools.com/howto/img_avatar.png"; // Nếu không có ảnh, hiển thị avatar mặc định
          _email = data['email'] ?? 'nomail@mail.com';
        });
      }
    } else {
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          SizedBox(
            height: kToolbarHeight, // Giới hạn chiều cao bằng AppBar
            child: Center(
              child: Image.asset('assets/images/logostar.png', width: 110),
            ),
          ),
          const SizedBox(width: 15),
        ],
        backgroundColor: Color.fromRGBO(217, 248, 217, 1),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            10 + 1,
          ), // 10px khoảng trống + 1px đường kẻ
          child: Column(
            children: [
              SizedBox(height: 10), // Tạo khoảng trống
              Container(
                height: 1, // Độ dày của đường gạch ngang
                color: Colors.green, // Màu đường kẻ
              ),
            ],
          ),
        ),
      ),
      drawer: CustomDrawer(
        username: _username,
        email: _email,
        imageUrl: _imageUrl,
      ),
      backgroundColor: Color.fromRGBO(217, 248, 217, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Story',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 95,
                  // color: Colors.red,
                  child: StoryScreen(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(top: 30, right: 30, left: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (ctx) => ArchiveScreen(userName: _username),
                            ),
                          );
                        },
                        label: const Text(
                          'Archive Chat',
                          style: TextStyle(fontSize: 16),
                        ),
                        icon: Icon(Icons.storage_outlined),
                      ),
                    ],
                  ),
                  ChatsScreen(userName: _username),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 216, 234, 216),
        currentIndex: _indexTab,
        onTap: (index) {
          setState(() {
            _indexTab = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            label: 'Chats',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Story'),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Cho phép mở rộng toàn màn hình nếu cần
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ), // Bo góc trên
            ),
            builder: (BuildContext context) {
              return AddMessageScreen();
            },
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ), // Bo góc nút giữa
        backgroundColor: const Color.fromARGB(255, 79, 176, 82),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // Đặt FAB ở giữa
    );
  }
}
