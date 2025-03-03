import 'dart:io';
import 'package:arkes_chat_app/screens/chat.dart';
import 'package:arkes_chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  @override
  State<CompleteProfileScreen> createState() {
    return _CompleteProfileScreenState();
  }
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _form = GlobalKey<FormState>();
  var _enteredUsername = '';
  File? _selectedImage;
  var _isSubmitting = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid || _selectedImage == null) {
      return;
    }
    _form.currentState!.save();

    try {
      setState(() {
        _isSubmitting = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user!.uid}.jpg');
      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'image_url': imageUrl,
          'username': _enteredUsername,
          'isProfileComplete': true,
        },
      );

      setState(() {
        _isSubmitting = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Something went wrong.')),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(110, 225, 179, 1),
      resizeToAvoidBottomInset: true, // Cho phép cuộn khi bàn phím xuất hiện
      body: Column(
        children: [
          const SizedBox(height: 90),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              'How people to know you?',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 35, // Giảm font size cho phù hợp
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                // Bọc phần nội dung cần cuộn
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 50,
                  ),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add profile picture',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: UserImagePicker(
                            onSelect: (image) {
                              _selectedImage = image;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Username',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 25),
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                            ),
                            hintText: "Username",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 4) {
                              return 'Please enter at least 4 characters.';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredUsername = newValue!;
                          },
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'Profile photos and username can be changed later.',
                            style: TextStyle(
                              color: Color.fromARGB(255, 95, 94, 94),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(300, 50),
                              backgroundColor: Color.fromRGBO(88, 170, 137, 1),
                            ),
                            child:
                                _isSubmitting
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                      'Get started!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ), // Khoảng trống tránh che nút bởi bàn phím
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
