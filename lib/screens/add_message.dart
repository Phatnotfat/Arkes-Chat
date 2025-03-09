import 'package:arkes_chat_app/providers/friends_provider.dart';
import 'package:arkes_chat_app/widgets/custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddMessageScreen extends ConsumerStatefulWidget {
  const AddMessageScreen({super.key});
  @override
  ConsumerState<AddMessageScreen> createState() {
    return _AddMessageScreenState();
  }
}

class _AddMessageScreenState extends ConsumerState<AddMessageScreen> {
  final TextEditingController _enteredMessage = TextEditingController();
  var isSending = false;
  String? _selectedFriendUid;
  var isEmpty = true;
  Map<String, Map<String, String>> _friendData = {}; // 🔹 Lưu thông tin bạn bè

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  Future<void> _loadFriendData() async {
    final friends = ref.read(friendsProvider);
    Map<String, Map<String, String>> tempData = {};

    for (var friend in friends) {
      final friendUid = friend['uid-friend'];
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(friendUid)
              .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        tempData[friendUid] = {
          'username': userData['username'] ?? 'Unknown',
          'image_url': userData['image_url'] ?? '',
        };
      }
    }

    if (mounted) {
      setState(() {
        _friendData = tempData;
      });
    }
  }

  /// **📩 Gửi tin nhắn**
  Future<void> _sendMessage() async {
    if (_selectedFriendUid == null || _enteredMessage.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isSending = true;
    });

    final senderId = FirebaseAuth.instance.currentUser!.uid;
    final receiverId = _selectedFriendUid!;
    final message = _enteredMessage.text.trim();
    final timestamp = Timestamp.now();

    // 🔹 **Tạo chatId (Ghép UID để đảm bảo thứ tự)**
    List<String> userIds = [senderId, receiverId];
    userIds.sort(); // Đảm bảo thứ tự để tránh trùng chatId
    final chatId = userIds.join('_');

    final newMessage = {
      'senderId': senderId,
      'text': message,
      'timestamp': timestamp,
      'readBy': [senderId],
    };

    // 🔹 **Thêm tin nhắn vào Firestore**
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('chats')
        .doc(chatId)
        .set({
          'lastMessage': message,
          'lastMessageAt': timestamp,
          'participantId': receiverId, // Lưu người trò chuyện với user
          'isArchived': false,
        }, SetOptions(merge: true));

    // 🔹 **Cập nhật tin nhắn cuối cùng trong danh sách chat của người nhận**
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(chatId)
        .set({
          'lastMessage': message,
          'lastMessageAt': timestamp,
          'participantId': senderId, // Lưu người trò chuyện với user
        }, SetOptions(merge: true));

    // 🔹 **Gửi push notification tới người nhận**
    sendPushNotification(receiverId, message);

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isSending = false;
    });
    // 🔹 **Đóng modal**
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Tiêu đề + Nút Cancel
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              Spacer(),
              Text(
                "Add Message",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 10),

          // 🔹 TextField Nhập Tin Nhắn
          CustomTextField(
            labelText: 'Message',
            controller: _enteredMessage,
            hintText: 'Enter a message',
            onTyping: (flag) {
              setState(() {
                isEmpty = flag;
              });
            },
          ),
          const SizedBox(height: 10),

          // 🔹 Hiển thị danh sách bạn bè để chọn
          Text('To:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),

          Expanded(
            child:
                friends.isEmpty
                    ? Center(child: Text('No friends available'))
                    : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (ctx, index) {
                        final friendUid = friends[index]['uid-friend'];
                        final userData = _friendData[friendUid];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                userData != null &&
                                        userData['image_url']!.isNotEmpty
                                    ? NetworkImage(userData['image_url']!)
                                    : AssetImage(
                                          'assets/images/user-avatar.png',
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(userData?['username'] ?? 'Loading...'),
                          tileColor:
                              _selectedFriendUid == friendUid
                                  ? Colors.green.withOpacity(0.3)
                                  : null,
                          onTap: () {
                            setState(() {
                              _selectedFriendUid = friendUid;
                            });
                          },
                        );
                      },
                    ),
          ),

          // 🔹 Nút Send
          SizedBox(height: 10),
          ElevatedButton(
            onPressed:
                _selectedFriendUid == null || isEmpty == true
                    ? null
                    : _sendMessage,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            child: isSending ? const CircularProgressIndicator() : Text('Send'),
          ),
        ],
      ),
    );
  }
}

/// **📌 Hàm gửi thông báo đẩy (Placeholder)**
void sendPushNotification(String receiverId, String message) {
  print('📩 Gửi push notification đến $receiverId: $message');
}
