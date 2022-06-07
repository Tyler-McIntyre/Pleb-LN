import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../util/app_colors.dart';

class QrCodeHelper {
  static QrImage createQrImage(String data) {
    return QrImage(
      data: data,
      version: QrVersions.auto,
      size: 270,
      gapless: false,
      backgroundColor: AppColors.white,
      embeddedImage: AssetImage('images/Pleb-logos_round.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(size: Size(60, 60)),
      errorStateBuilder: (cxt, err) {
        return Container(
          child: Center(
            child: Text(
              'Uh oh! Something went wrong...',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
