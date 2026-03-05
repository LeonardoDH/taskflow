import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroAuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color hintColor;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const RetroAuthField({
    super.key,
    required this.controller,
    required this.hint,
    this.hintColor = Colors.black38,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(
          top: BorderSide(color: Colors.black38, width: 2),
          left: BorderSide(color: Colors.black38, width: 2),
          bottom: BorderSide(color: Colors.white, width: 2),
          right: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: hintColor,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class RetroAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool secondary;

  const RetroAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: secondary ? const Color(0xFFCCCCCC) : const Color(0xFFDDDDDD),
          border: const Border(
            top: BorderSide(color: Colors.white, width: 2),
            left: BorderSide(color: Colors.white, width: 2),
            bottom: BorderSide(color: Colors.black54, width: 2),
            right: BorderSide(color: Colors.black54, width: 2),
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0040FF),
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 11,
                    color: const Color(0xFF0040FF),
                  ),
                ),
        ),
      ),
    );
  }
}
