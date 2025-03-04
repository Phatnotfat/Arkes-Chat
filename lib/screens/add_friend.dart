import 'package:arkes_chat_app/widgets/custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});
  @override
  State<AddFriendScreen> createState() {
    return _AddFriendScreen();
  }
}

class _AddFriendScreen extends State<AddFriendScreen> {
  final _emailController = TextEditingController();
  var _isAdding = false;

  void snackBarResult(String result) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  Future<void> sendFriendRequest(String friendEmail) async {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    setState(() {
      _isAdding = true;
    });
    try {
      // Tìm user theo email trong Firestore
      final querySnapshot =
          await firestore
              .collection('users')
              .where('email', isEqualTo: friendEmail) //  Tìm theo email
              .limit(1) // Giới hạn chỉ lấy 1 kết quả
              .get();

      //  Nếu không tìm thấy user, return
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isAdding = false;
        });

        snackBarResult('Email does not exist');
        print("Email không tồn tại");
        return;
      }

      //Lấy UID từ document tìm thấy
      final friendUid = querySnapshot.docs.first.id; // UID là document ID

      // **2️⃣ Kiểm tra xem đã là bạn bè chưa**
      final DocumentSnapshot currentUserFriendsSnapshot =
          await firestore.collection('friends').doc(currentUserUid).get();

      if (currentUserFriendsSnapshot.exists) {
        final List<dynamic> currentUserFriends = List.from(
          currentUserFriendsSnapshot['friends'] ?? [],
        );

        // **Kiểm tra xem friendUid có trong danh sách bạn bè không**
        bool isAlreadyFriend = currentUserFriends.any(
          (friend) => friend['uid-friend'] == friendUid,
        );

        if (isAlreadyFriend) {
          setState(() {
            _isAdding = false;
          });
          snackBarResult('You are already friends');
          print("Bạn đã là bạn bè của nhau");
          return;
        }
      }

      //  Kiểm tra nếu đã gửi lời mời trước đó (tránh gửi trùng)
      final sentRequestDoc =
          await firestore
              .collection('sent_request_friends')
              .doc(currentUserUid)
              .get();

      if (sentRequestDoc.exists) {
        List<dynamic> sentRequests =
            sentRequestDoc.data()?['sent_requests'] ?? [];
        bool alreadySent = sentRequests.any(
          (req) => req['uid-receive'] == friendUid,
        );

        if (alreadySent) {
          setState(() {
            _isAdding = false;
          });
          snackBarResult('Friend request already sent');
          print("Đã gửi lời mời trước đó");
          return;
        }
      }

      final currentTime = Timestamp.now();

      //  Thêm vào danh sách `sent_request_friends`
      await firestore
          .collection('sent_request_friends')
          .doc(currentUserUid)
          .set({
            'sent_requests': FieldValue.arrayUnion([
              {'uid-receive': friendUid, 'createdAt': currentTime},
            ]),
          }, SetOptions(merge: true));

      // Thêm vào danh sách `receive_request_friends` của người nhận
      await firestore.collection('receive_request_friends').doc(friendUid).set({
        'receive_requests': FieldValue.arrayUnion([
          {'uid-send': currentUserUid, 'createdAt': currentTime},
        ]),
      }, SetOptions(merge: true));

      setState(() {
        _isAdding = false;
      });
      snackBarResult('Friend request sent successfully');
      print("Gửi kết bạn thành công");
    } catch (error) {
      setState(() {
        _isAdding = false;
      });
      snackBarResult('Failed to send friend request');

      print("Lỗi khi gửi lời mời kết bạn: $error");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('data')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text(
              'Make Friend with email or google',
              style: TextStyle(fontSize: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _emailController,
              hintText: 'Enter a mail',
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed:
                  _isAdding
                      ? null
                      : () async {
                        // xử lí chưa kỹ
                        var enteredEmail = _emailController.value.text;
                        if (enteredEmail == null ||
                            enteredEmail.trim().isEmpty) {
                          return;
                        }
                        await sendFriendRequest(enteredEmail);
                      },
              child:
                  _isAdding
                      ? const SizedBox(
                        width: 30, // Độ rộng mong muốn
                        height: 30, // Độ cao mong muốn
                        child: CircularProgressIndicator(),
                      )
                      : Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
