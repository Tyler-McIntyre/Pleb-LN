import 'package:flutter/material.dart';

import '../../util/app_colors.dart';

class FutureBuilderWidgets {
  static Widget error(BuildContext context, String exception) {
    String message =
        exception.replaceAll('Exception:', '').replaceAll('Error:', '');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 45,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            message,
            style: TextStyle(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  static Widget circularProgressIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}
