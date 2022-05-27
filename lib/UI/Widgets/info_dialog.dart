import 'package:flutter/material.dart';
import '../../util/app_colors.dart';

enum DialogType { OpenChannelNodeAlias, ChannelFee, MinimumConfirmations }

class InfoDialog {
  Map<DialogType, String> blurbs = {
    DialogType.OpenChannelNodeAlias:
        'Assign this node a nickname for organizational purposes. If a nickname is not specified then the channel ID will be listed on the dashboard instead. This is saved locally so if you delete the application from your phone, this information will be lost.',
    DialogType.ChannelFee:
        'A manual fee rate set in sat/vbyte that should be used when crafting the funding transaction.',
    DialogType.MinimumConfirmations:
        'this is the minimum number of confirmations each one of your outputs used for the funding transaction must satisfy'
  };
  Future<void> showMyDialog(String body, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            Icons.info_outline,
            color: AppColors.blue,
            size: 35,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.black, fontSize: 20),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Got it!',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
