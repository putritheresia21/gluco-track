import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final IconData? icon;
  final String? hint;
  final TextEditingController controller;
  final bool? obscureText;
  final double? borderRadius;
  final double? width;

  const CustomInputField({
    Key? key,
    this.icon,
    this.hint,
    required this.controller,
    this.obscureText,
    this.borderRadius,
    this.width,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, color: Colors.grey)
              : null,
          suffixIcon: widget.obscureText == true
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}
