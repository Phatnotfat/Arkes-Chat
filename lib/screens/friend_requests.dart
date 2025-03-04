import 'package:arkes_chat_app/providers/friend_requests_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestFriendScreen extends ConsumerWidget {
  const RequestFriendScreen({super.key});

  /// **Hàm lấy thông tin user từ Firestore dựa vào UID**
  Future<Map<String, dynamic>?> _fetchUserInfo(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data();
    }
    return null;
  }

  /// **Hiển thị SnackBar thông báo (có kiểm tra mounted)**
  void _showSnackBar(BuildContext context, String message, Color color) {
    if (!context.mounted) return; // Kiểm tra nếu màn hình đã bị unmounted

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendRequests = ref.watch(
      friendRequestsProvider,
    ); // Lắng nghe thay đổi

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body:
          friendRequests.isEmpty
              ? const Center(child: Text('No friend requests'))
              : ListView.builder(
                itemCount: friendRequests.length,
                itemBuilder: (ctx, index) {
                  final request = friendRequests[index];
                  final senderUid =
                      request['uid-send']; // Lấy UID của người gửi

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchUserInfo(senderUid),
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
                          'Received at: ${request['createdAt'].toDate()}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // **Nút chấp nhận**
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () async {
                                await ref
                                    .read(friendRequestsProvider.notifier)
                                    .acceptRequestFriend(senderUid);
                                _showSnackBar(
                                  context,
                                  'Accepted friend request from ${userData['username']}!',
                                  Colors.green,
                                );
                              },
                            ),
                            // **Nút từ chối**
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await ref
                                    .read(friendRequestsProvider.notifier)
                                    .rejectRequestFriend(senderUid);
                                _showSnackBar(
                                  context,
                                  'Rejected friend request from ${userData['username']}.',
                                  Colors.red,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
