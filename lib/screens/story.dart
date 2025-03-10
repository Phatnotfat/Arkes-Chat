import 'package:arkes_chat_app/widgets/item_story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arkes_chat_app/providers/friends_provider.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});
  @override
  ConsumerState<StoryScreen> createState() {
    return _StoryScreenState();
  }
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  Future<Map<String, dynamic>?> _fetchUserInfo(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    return friends.isEmpty
        ? ItemStory()
        : ListView.builder(
          shrinkWrap: true, // Giúp ListView chỉ chiếm kích thước cần thiết
          scrollDirection: Axis.horizontal, // Nếu bạn muốn cuộn ngang

          itemCount: friends.length,
          itemBuilder: (ctx, index) {
            final friend = friends[index];
            final friendUid = friend['uid-friend']; // UID của bạn bè
            return FutureBuilder(
              future: _fetchUserInfo(friendUid),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ItemStory();
                }
                if (!snapshot.hasData) {
                  return ItemStory(userName: 'error');
                }
                final userData = snapshot.data!;
                return ItemStory(
                  userName: userData['username'],
                  imageUrl: userData['image_url'],
                );
              },
            );
          },
        );
  }
}
