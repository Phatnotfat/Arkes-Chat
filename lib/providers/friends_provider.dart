import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// **1. StateNotifier để lắng nghe Firestore**
class FriendsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FriendsNotifier() : super([]) {
    _listenToFriends();
  }

  /// **2. Lắng nghe Firestore khi có request mới**
  void _listenToFriends() {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUserUid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            List<Map<String, dynamic>> friends =
                List<Map<String, dynamic>>.from(data['friends'] ?? []);
            state = friends; // Cập nhật state với danh sách bạn mới
          } else {
            state = [];
          }
        });
  }
}

/// **3. Tạo StateNotifierProvider để dùng trong UI**
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, List<Map<String, dynamic>>>(
      (ref) => FriendsNotifier(),
    );
