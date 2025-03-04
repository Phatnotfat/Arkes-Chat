import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});
  @override
  State<ChatsScreen> createState() {
    return _ChatsScreenState();
  }
}

class _ChatsScreenState extends State<ChatsScreen> {
  /// **Định dạng thời gian từ Timestamp**
  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .collection('chats')
              .orderBy('lastMessageAt', descending: true)
              .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No conversations yet'));
        }

        final chatDocs = snapshot.data!.docs;

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
                    return ListTile(
                      title: Text("Loading..."),
                      subtitle: Text("..."),
                    );
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 29,
                          backgroundImage:
                              userData['image_url'] != null
                                  ? NetworkImage(userData['image_url'])
                                  : const AssetImage(
                                        'assets/images/user-avatar.png',
                                      )
                                      as ImageProvider,
                        ),
                        Positioned(
                          bottom: 1.5,
                          right: 1.5,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(
                                width: 1.5,
                                color: Colors.white,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor:
                                  Colors
                                      .green, // Cần thay đổi theo trạng thái online
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      userData['username'] ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      chatData['lastMessage'] ?? 'No messages yet',
                    ),
                    trailing: Text(
                      _formatTimestamp(chatData['lastMessageAt']),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      // Xử lý mở màn hình chat với chatId
                    },
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
