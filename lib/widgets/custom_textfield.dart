import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final String hintText;

  final Function(bool flag)? onTyping;
  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText = '',
    this.isPassword = false,
    this.validator,
    this.hintText = '',
    this.onTyping,
  });

  @override
  State<CustomTextField> createState() {
    return _CustomTextFieldState();
  }
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true; // Mặc định che password

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: (value) {
        if (widget.onTyping != null) {
          if (value.trim().isNotEmpty) {
            widget.onTyping!(false); // Gọi nếu có truyền vào
          } else {
            widget.onTyping!(true);
          }
        }
      },
      obscureText: widget.isPassword ? _obscureText : false,
      validator: widget.validator,
      keyboardType: !widget.isPassword ? TextInputType.emailAddress : null,
      decoration: InputDecoration(
        hintText: widget.hintText == '' ? null : widget.hintText,
        contentPadding: const EdgeInsets.all(15),

        labelText: widget.labelText == '' ? null : widget.labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.onPrimary,
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Color.fromRGBO(88, 170, 137, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : Icon(Icons.email, color: Color.fromRGBO(88, 170, 137, 1)),
      ),
    );
  }
}
