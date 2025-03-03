import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onSelect});

  final void Function(File image) onSelect;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _selectedImage;
  var _isLoading = false;

  void _pickImage() async {
    setState(() {
      _isLoading = true;
    });
    final ImagePicker picker = ImagePicker();
    final pickImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickImage == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _selectedImage = File(pickImage.path);
      _isLoading = false;
    });
    widget.onSelect(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          foregroundImage:
              _selectedImage == null
                  ? AssetImage('assets/images/user-avatar.png')
                  : null,
          radius: 70,
          backgroundImage:
              _selectedImage != null ? FileImage(_selectedImage!) : null,
          backgroundColor: const Color.fromARGB(255, 222, 221, 221),
        ),
        if (_isLoading)
          Positioned(
            top: 50,
            right: 50,

            child: const CircularProgressIndicator(
              backgroundColor: Colors.grey,
            ),
          ),
        Positioned(
          bottom: 0,
          right: 5,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.camera_alt, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
