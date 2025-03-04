import 'package:flutter/material.dart';

class BubbleMessage extends StatelessWidget {
  const BubbleMessage({
    super.key,
    this.imgUrl,
    required this.message,
    required this.isMe,
  });
  final String? imgUrl;
  final String message;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          !isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (imgUrl != null && isMe == false)
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5, right: 5),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(imgUrl!),
            ),
          ),
        if (imgUrl == null) const SizedBox(width: 55),
        Container(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width * 0.65, // Giới hạn tối đa 80%
          ),
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color:
                !isMe
                    ? Color.fromRGBO(233, 255, 242, 1)
                    : Color.fromRGBO(0, 109, 88, 1),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),

          child: Text(
            message,
            style: TextStyle(
              color: !isMe ? Colors.black : Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
