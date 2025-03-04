import 'package:arkes_chat_app/widgets/bubble_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({
    super.key,
    required this.chatId,
    required this.imgUrl,
  });
  final String chatId; // Nhận chatId từ ChatScreen
  final String imgUrl;

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  @override
  Widget build(BuildContext context) {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatId)
              .collection('messages')
              .orderBy(
                'timestamp',
                descending: true,
              ) // Sắp xếp tin nhắn mới nhất trước
              .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true, // Hiển thị tin nhắn mới nhất ở cuối
          itemCount: messages.length,
          itemBuilder: (ctx, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            final bool isMe = messageData['senderId'] == currentUserUid;

            final nextMessageData =
                index + 1 < messages.length
                    ? messages[index + 1].data() as Map<String, dynamic>
                    : null;
            final beforeMessageData =
                index - 1 < 0
                    ? null
                    : messages[index - 1].data() as Map<String, dynamic>;
            final currentMessageUserId = messageData['senderId'];
            final nextMessageUserId =
                nextMessageData != null ? nextMessageData['senderId'] : null;
            final beforeMessageUserId =
                beforeMessageData != null
                    ? beforeMessageData['senderId']
                    : null;
            final nextUserIsSame = currentMessageUserId == nextMessageUserId;
            final beforeUserIsSame =
                currentMessageUserId == beforeMessageUserId;
            // print(nextUserIsSame);
            // print(index);
            if (nextUserIsSame) {
              if (!beforeUserIsSame) {
                return BubbleMessage(
                  message: messageData['text'],
                  isMe: isMe,
                  imgUrl:
                      widget
                          .imgUrl, // Avatar chỉ hiển thị với tin nhắn của người khác
                );
              }
              return BubbleMessage(message: messageData['text'], isMe: isMe);
            } else {
              if (beforeUserIsSame) {
                return BubbleMessage(message: messageData['text'], isMe: isMe);
              } else {
                return BubbleMessage(
                  message: messageData['text'],
                  isMe: isMe,
                  imgUrl:
                      widget
                          .imgUrl, // Avatar chỉ hiển thị với tin nhắn của người khác
                );
              }
            }
          },
        );
      },
    );
  }
}
