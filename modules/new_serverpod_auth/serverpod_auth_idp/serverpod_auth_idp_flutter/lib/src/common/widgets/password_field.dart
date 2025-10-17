import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isLoading;

  const PasswordField({
    this.labelText = 'Password',
    required this.controller,
    this.isLoading = false,
    super.key,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: !widget.isLoading,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          icon: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              key: ValueKey<bool>(_passwordVisible),
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
