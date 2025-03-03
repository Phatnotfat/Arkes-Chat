import 'package:arkes_chat_app/screens/splash.dart';
import 'package:arkes_chat_app/widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                Container(
                  height: 95,
                  // color: Colors.red,
                  child: ListView.builder(
                    shrinkWrap:
                        true, // Giúp ListView chỉ chiếm kích thước cần thiết
                    scrollDirection: Axis.horizontal, // Nếu bạn muốn cuộn ngang

                    itemCount: 10,
                    itemBuilder: (ctx, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 7.8),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green, // Màu viền
                                  width: 3, // Độ dày viền
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 29, // Kích thước avatar
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  150,
                                  242,
                                  170,
                                ),
                                child: Text(
                                  index.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text('Name ${index}'),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
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
                        onPressed: () {},
                        label: const Text(
                          'Archive Chat',
                          style: TextStyle(fontSize: 16),
                        ),
                        icon: Icon(Icons.storage_outlined),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(radius: 29),
                              Positioned(
                                bottom: 1.5,
                                right: 1.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            'Trần Tiến Phát',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('Hôm nay không có học bài'),
                        );
                      },
                    ),
                  ),
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
        onPressed: () {},
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
