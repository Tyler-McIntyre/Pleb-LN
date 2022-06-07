import 'package:flutter/material.dart';

import '../../util/app_colors.dart';

class Snackbars {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> error(
      BuildContext context, String exception) {
    String message = exception.replaceAll('Exception:', '');

    final snackBar = SnackBar(
      duration: Duration(seconds: 5),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      backgroundColor: (AppColors.red),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> invalid(
      BuildContext context, String input) {
    final snackBar = SnackBar(
      content: Text(
        'Invalid $input',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
      backgroundColor: (AppColors.red),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> comingSoon(
      BuildContext context, String feature) {
    final snackBar = SnackBar(
      content: Text(
        'Coming Soon -> $feature!',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
      ),
      backgroundColor: (AppColors.grey),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
