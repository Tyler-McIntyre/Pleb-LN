import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class ClipboardHelper {
  static Future<void> copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: AppColors.orange,
      content: Text('Copied to clipboard'),
    ));
  }
}
