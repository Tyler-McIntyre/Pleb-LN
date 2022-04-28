import 'package:flutter/material.dart';

class CustomSnackbar extends StatefulWidget {
  const CustomSnackbar({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  State<CustomSnackbar> createState() => _CustomSnackbarState();
}

class _CustomSnackbarState extends State<CustomSnackbar> {
  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(widget.message),
      backgroundColor: (Colors.black12),
    );
  }
}
