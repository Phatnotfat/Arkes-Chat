import 'package:arkes_chat_app/providers/friends_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendScreen extends ConsumerWidget {
  const FriendScreen({super.key});

  Future<Map<String, dynamic>?> _fetchUserInfo(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider); // Lắng nghe thay đổi

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body:
          friends.isEmpty
              ? const Center(child: Text('No friends'))
              : ListView.builder(
                itemCount: friends.length,
                itemBuilder: (ctx, index) {
                  final friend = friends[index];
                  final friendUid = friend['uid-friend']; // UID của bạn bè

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchUserInfo(friendUid),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          leading: CircleAvatar(
                            child: CircularProgressIndicator(),
                          ),
                          title: Text('Loading...'),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const ListTile(
                          leading: CircleAvatar(child: Icon(Icons.error)),
                          title: Text('User not found'),
                        );
                      }

                      final userData = snapshot.data!;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              userData['image_url'].isNotEmpty
                                  ? NetworkImage(userData['image_url'])
                                  : const AssetImage(
                                        'assets/images/default_avatar.png',
                                      )
                                      as ImageProvider,
                        ),
                        title: Text(userData['username'] ?? 'Unknown User'),
                        subtitle: Text(
                          'Make friend at: ${friend['createdAt'].toDate()}',
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
