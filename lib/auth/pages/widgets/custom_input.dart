import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Variabel buat nyimpen status apakah teks lagi disensor atau nggak
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword; 
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _isObscured, // Pake variabel state
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () {
                  // Pas diklik, ubah status sensornya
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
            
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF2563EB),
          ),
          borderRadius: BorderRadius.circular(10)
        ),
        hintText: widget.hintText,
      ),
    );
  }
}