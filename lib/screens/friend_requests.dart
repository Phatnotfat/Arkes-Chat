import 'package:arkes_chat_app/providers/friend_requests_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestFriendScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendRequests = ref.watch(
      friendRequestsProvider,
    ); // Lắng nghe thay đổi

    return Scaffold(
      appBar: AppBar(title: Text('Friend Requests')),
      body:
          friendRequests.isEmpty
              ? Center(child: Text('No friend requests'))
              : ListView.builder(
                itemCount: friendRequests.length,
                itemBuilder: (ctx, index) {
                  final request = friendRequests[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(request['uid-send'][0].toUpperCase()),
                    ), // Lấy chữ cái đầu của UID
                    title: Text('User ID: ${request['uid-send']}'),
                    subtitle: Text(
                      'Received at: ${request['createdAt'].toDate()}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        print('Accept request: ${request['uid-send']}');
                      },
                    ),
                  );
                },
              ),
    );
  }
}
