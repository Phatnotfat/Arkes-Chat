import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// **1. StateNotifier để lắng nghe Firestore**
class FriendRequestsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FriendRequestsNotifier() : super([]) {
    _listenToFriendRequests();
  }

  /// **2. Lắng nghe Firestore khi có request mới**
  void _listenToFriendRequests() {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('receive_request_friends')
        .doc(currentUserUid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            List<Map<String, dynamic>> requests =
                List<Map<String, dynamic>>.from(data['receive_requests'] ?? []);
            state =
                requests; // Cập nhật state với danh sách yêu cầu kết bạn mới
          } else {
            state = [];
          }
        });
  }
}

/// **3. Tạo StateNotifierProvider để dùng trong UI**
final friendRequestsProvider =
    StateNotifierProvider<FriendRequestsNotifier, List<Map<String, dynamic>>>(
      (ref) => FriendRequestsNotifier(),
    );
