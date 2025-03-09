import 'package:arkes_chat_app/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key, required this.userName});
  final String userName;

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  /// **Chuyển đổi `Timestamp` thành định dạng thời gian**
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Unknown";
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "Invalid Time";
  }

  /// **Hàm bỏ lưu trữ (Unarchive) cuộc trò chuyện**
  Future<void> _unarchiveChat(String chatId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('chats')
        .doc(chatId)
        .update({'isArchived': false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Archived Chats")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserUid)
                .collection('chats')
                .where('isArchived', isEqualTo: true)
                .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No archived conversations.'));
          }

          // 🔥 Sắp xếp danh sách theo `lastMessageAt`
          List<QueryDocumentSnapshot> chatDocs = snapshot.data!.docs;
          chatDocs.sort((a, b) {
            Timestamp timeA = a['lastMessageAt'];
            Timestamp timeB = b['lastMessageAt'];
            return timeB.compareTo(timeA);
          });

          return ListView.builder(
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
                    direction:
                        DismissDirection
                            .endToStart, // 🔄 Vuốt PHẢI để khôi phục
                    onDismissed: (direction) {
                      _unarchiveChat(chatId);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.orange,
                      child: Icon(
                        Icons.unarchive,
                        color: Colors.white,
                        size: 28,
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
          );
        },
      ),
    );
  }
}
