import 'package:arkes_chat_app/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, required this.userName});
  final String userName;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  /// **Hàm chuyển đổi `Timestamp` thành định dạng thời gian**
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "No time"; // Nếu null, hiển thị "No time"
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "Invalid Time"; // Tránh lỗi nếu có kiểu dữ liệu khác
  }

  /// **Hàm lưu trữ (Archive) cuộc trò chuyện**
  Future<void> _archiveChat(String chatId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('chats')
        .doc(chatId)
        .update({'isArchived': true});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .collection('chats')
              .where(
                'isArchived',
                isEqualTo: false,
              ) // 🔥 Chỉ lấy chat chưa lưu trữ
              .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No conversations yet'));
        }

        // 🔥 Lấy danh sách và sắp xếp theo `lastMessageAt`
        // 🔥 Lấy danh sách và sắp xếp theo `lastMessageAt`
        List<QueryDocumentSnapshot> chatDocs = snapshot.data!.docs;
        chatDocs.sort((a, b) {
          Timestamp? timeA = a['lastMessageAt'] as Timestamp?;
          Timestamp? timeB = b['lastMessageAt'] as Timestamp?;

          if (timeA == null && timeB == null)
            return 0; // Nếu cả hai đều null, giữ nguyên vị trí
          if (timeA == null)
            return 1; // Nếu `timeA` null, đẩy nó xuống cuối danh sách
          if (timeB == null)
            return -1; // Nếu `timeB` null, đẩy nó xuống cuối danh sách

          return timeB.compareTo(timeA); // Sắp xếp theo thời gian giảm dần
        });

        return Expanded(
          child: ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              final chatId = chatDocs[index].id;
              final participantId = chatData['participantId'];

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(participantId)
                        .get(),
                builder: (ctx, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(title: Text("Loading..."));
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return Dismissible(
                    key: Key(chatId),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _archiveChat(chatId);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.archive, color: Colors.white, size: 28),
                          Text(
                            'Archived',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 29,
                            backgroundImage:
                                userData['image_url'] != null
                                    ? NetworkImage(userData['image_url'])
                                    : AssetImage(
                                          'assets/images/user-avatar.png',
                                        )
                                        as ImageProvider,
                          ),
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
                        userData['username'] ?? 'Unknown User',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        chatData['lastMessage'] ?? 'No messages yet',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        chatData['lastMessageAt'] != null
                            ? _formatTimestamp(chatData['lastMessageAt'])
                            : "Pending...",
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (ctx) => ChatScreen(
                                  currentUserName: widget.userName,
                                  userName: userData['username'],
                                  imageUrl: userData['image_url'],
                                  chatId: chatId,
                                  participantId: participantId,
                                  tokenNotificationParticipant:
                                      userData['notificationToken'] ?? '',
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
