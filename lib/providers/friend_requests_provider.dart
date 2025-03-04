import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// **1. StateNotifier để lắng nghe Firestore**
class FriendRequestsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  StreamSubscription? _subscription;

  FriendRequestsNotifier() : super([]) {
    _listenToFriendRequests();
  }

  /// **2. Lắng nghe Firestore khi có request mới**
  void _listenToFriendRequests() {
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) return;

    // Hủy lắng nghe dữ liệu cũ trước khi lắng nghe UID mới
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('receive_request_friends')
        .doc(currentUserUid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            List<Map<String, dynamic>> requests =
                List<Map<String, dynamic>>.from(data['receive_requests'] ?? []);
            state = requests; // Cập nhật danh sách yêu cầu kết bạn
          } else {
            state = [];
          }
        });
  }

  /// **3. Cập nhật lắng nghe khi tài khoản thay đổi**
  void updateListener() {
    _listenToFriendRequests();
  }

  Future<void> removeRequestByUid(
    String collectionRequest,
    String userId,
    String sendUid,
  ) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    var arrayName = '';
    var uidName = '';
    var docNameId = '';
    var personUid = '';
    if (collectionRequest == 'receive_request_friends') {
      arrayName = 'receive_requests';
      uidName = 'uid-send';
      docNameId = userId;
      personUid = sendUid;
    } else {
      arrayName = 'sent_requests';
      uidName = 'uid-receive';
      docNameId = sendUid;
      personUid = userId;
    }
    print(docNameId);

    final DocumentReference requestRef = firestore
        .collection(collectionRequest)
        .doc(docNameId);

    // Lấy dữ liệu hiện tại từ Firestore
    final snapshot = await requestRef.get();
    if (!snapshot.exists) return;

    final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    if (data == null || !data.containsKey(arrayName)) return;

    final List<Map<String, dynamic>> arrayRequests = List.from(
      data[arrayName] ?? [],
    );

    //Xoá phần tử có uid-send = senderUid**
    arrayRequests.removeWhere((req) => req[uidName] == personUid);

    // Cập nhật lại danh sách
    await requestRef.update({arrayName: arrayRequests});

    if (collectionRequest == 'receive_request_friends') {
      state = arrayRequests;
    }
    print("✅ Đã xoá yêu cầu kết bạn từ $personUid!");
  }

  Future<void> acceptRequestFriend(String sendUid) async {
    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await removeRequestByUid('receive_request_friends', userUid, sendUid);
      await removeRequestByUid('sent_request_friends', userUid, sendUid);

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final Timestamp createdAt = Timestamp.now();

      // Tạo batch để thực hiện nhiều thao tác cùng lúc
      WriteBatch batch = firestore.batch();

      //  Cập nhật danh sách bạn bè của currentUid**
      final DocumentReference currentUserRef = firestore
          .collection('friends')
          .doc(userUid);

      batch.set(currentUserRef, {
        'friends': FieldValue.arrayUnion([
          {'uid-friend': sendUid, 'createdAt': createdAt},
        ]),
      }, SetOptions(merge: true));

      // Cập nhật danh sách bạn bè của sendUid**
      final DocumentReference sendUserRef = firestore
          .collection('friends')
          .doc(sendUid);

      batch.set(sendUserRef, {
        'friends': FieldValue.arrayUnion([
          {'uid-friend': userUid, 'createdAt': createdAt},
        ]),
      }, SetOptions(merge: true));

      // Commit batch để cập nhật Firestore
      await batch.commit();

      print("✅ Đã thêm bạn thành công giữa $userUid và $sendUid!");
      print('Thành công ');
    } catch (error) {
      print(error);
    }
  }

  Future<void> rejectRequestFriend(String sendUid) async {
    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await removeRequestByUid('receive_request_friends', userUid, sendUid);
      await removeRequestByUid('sent_request_friends', userUid, sendUid);

      print('Từ chối thành công');
    } catch (error) {
      print(error);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Hủy lắng nghe khi Provider bị hủy
    super.dispose();
  }
}

/// **3. Tạo StateNotifierProvider để dùng trong UI**
final friendRequestsProvider =
    StateNotifierProvider<FriendRequestsNotifier, List<Map<String, dynamic>>>(
      (ref) => FriendRequestsNotifier(),
    );
