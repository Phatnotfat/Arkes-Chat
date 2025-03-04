import 'package:arkes_chat_app/widgets/chat_input_field.dart';
import 'package:arkes_chat_app/widgets/message_listview.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.userName,
    required this.imageUrl,
    required this.chatId,
    required this.participantId,
  });
  final String participantId;
  final String userName;
  final String imageUrl;
  final String chatId;
  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(170, 212, 190, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(170, 212, 190, 1),
        titleSpacing: 0,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(1, 103, 63, 1),
            size: 27,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.amber[50],
                  foregroundImage: NetworkImage(widget.imageUrl),
                ),
                Positioned(
                  bottom: -1.5,
                  right: -1.3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        width: 1.7,
                        color: Color.fromRGBO(170, 212, 190, 1),
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor:
                          Colors.green, // Cần thay đổi theo trạng thái online
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Active now",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(76, 92, 82, 1),
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.call,
                color: Color.fromRGBO(1, 103, 63, 1),
                size: 28,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.videocam_rounded,
                color: Color.fromRGBO(1, 103, 63, 1),
                size: 34,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageListView(
              chatId: widget.chatId,
              imgUrl: widget.imageUrl,
            ),
          ), // Danh sách tin nhắn
          ChatInputField(
            receiverId: widget.participantId,
          ), // Thanh nhập tin nhắn
        ],
      ),
    );
  }
}
