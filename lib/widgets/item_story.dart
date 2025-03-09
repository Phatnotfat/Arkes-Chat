import 'package:flutter/material.dart';

class ItemStory extends StatelessWidget {
  const ItemStory({super.key, this.imageUrl, this.userName});
  final String? imageUrl;
  final String? userName;
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 7.8, bottom: 5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green, // Màu viền
                width: 3, // Độ dày viền
              ),
            ),
            child: CircleAvatar(
              radius: 29, // Kích thước avatar
              // backgroundColor: const Color.fromARGB(255, 150, 242, 170),
              backgroundImage:
                  imageUrl == null
                      ? AssetImage('assets/images/user-avatar.png')
                      : NetworkImage(imageUrl!),
              child:
                  userName == null
                      ? const CircularProgressIndicator()
                      : const Text(''),
            ),
            // Text(
            //   contentText,
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
          ),
        ),

        Row(
          children: [
            Text(
              userName == null ? '' : userName!.trim().split(' ').first,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}
