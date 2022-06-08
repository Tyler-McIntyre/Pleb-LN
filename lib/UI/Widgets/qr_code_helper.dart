import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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

  Future<String> scanQrCode(bool mounted) async {
    try {
      String qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#E62119', 'Cancel', true, ScanMode.QR);

      if (!mounted) return '';

      return qrCode;
    } on PlatformException {
      throw Exception('Failed to get platform version.');
    }
  }
}
