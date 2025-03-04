import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  StreamSubscription? _subscription;

  FriendsNotifier() : super([]) {
    _listenToFriends();
  }

  /// * Lắng nghe danh sách bạn bè**
  void _listenToFriends() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Nếu chưa đăng nhập, thoát

    final String currentUserUid = user.uid;

    // Hủy lắng nghe UID cũ trước khi lắng nghe UID mới
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUserUid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            List<Map<String, dynamic>> friends =
                List<Map<String, dynamic>>.from(data['friends'] ?? []);
            state = friends; // Cập nhật danh sách bạn bè mới
          } else {
            state = [];
          }
        });
  }

  ///  Cập nhật lắng nghe khi đăng nhập tài khoản khác**
  void updateListener() {
    _listenToFriends(); //  Gọi lại lắng nghe sau khi đăng nhập lại
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Hủy lắng nghe khi Provider bị hủy
    super.dispose();
  }
}

///  Tạo Provider**
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, List<Map<String, dynamic>>>(
      (ref) => FriendsNotifier(),
    );
