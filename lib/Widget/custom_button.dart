import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final Color? isLoadingColor;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.isLoading,
    this.isLoadingColor,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        child: widget.isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isLoadingColor ?? Colors.white),
              )
            : Text(
                widget.text,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
