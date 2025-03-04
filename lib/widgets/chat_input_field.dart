import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({super.key, required this.receiverId});
  final String receiverId;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController messageController = TextEditingController();

  Future<void> _sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    final senderId = FirebaseAuth.instance.currentUser!.uid;
    final message = messageController.text.trim();
    final timestamp = FieldValue.serverTimestamp();

    setState(() {
      messageController.clear();
    });
    // 🔹 **Tạo chatId (Ghép UID để đảm bảo thứ tự)**
    List<String> userIds = [senderId, widget.receiverId];
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
          'participantId': widget.receiverId, // Lưu người trò chuyện với user
        }, SetOptions(merge: true));

    // 🔹 **Cập nhật tin nhắn cuối cùng trong danh sách chat của người nhận**
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .collection('chats')
        .doc(chatId)
        .set({
          'lastMessage': message,
          'lastMessageAt': timestamp,
          'participantId': senderId, // Lưu người trò chuyện với user
        }, SetOptions(merge: true));

    // 🔹 **Gửi push notification tới người nhận**
    sendPushNotification(widget.receiverId, message);

    await Future.delayed(Duration(seconds: 1));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 8,
      ), // Giảm padding tổng thể
      decoration: BoxDecoration(
        color: Color.fromRGBO(170, 212, 190, 1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Giữ các icon cân đối
        children: [
          Row(
            children: [
              _buildIcon(Icons.camera_alt),
              _buildIcon(Icons.image),
              _buildIcon(Icons.mic),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              margin: const EdgeInsets.symmetric(
                horizontal: 6,
              ), // Giảm margin giữa input và icon
              decoration: BoxDecoration(
                color: Color.fromRGBO(201, 243, 219, 1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: "Aa",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _buildIcon(Icons.emoji_emotions_outlined),
                ],
              ),
            ),
          ),
          _buildIcon(Icons.send),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ), // Giảm khoảng cách giữa các icon
      child: IconButton(
        icon: Icon(
          icon,
          color: Color.fromRGBO(1, 108, 100, 1),
          size: 28,
        ), // Giảm size icon
        onPressed: icon == Icons.send ? _sendMessage : null,
        padding: EdgeInsets.zero, // Loại bỏ padding mặc định
        constraints: const BoxConstraints(), // Loại bỏ giới hạn mặc định
        visualDensity: VisualDensity.compact, // Giảm mật độ khoảng cách
      ),
    );
  }
}

void sendPushNotification(String receiverId, String message) {
  print('📩 Gửi push notification đến $receiverId: $message');
}
