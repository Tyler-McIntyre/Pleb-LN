import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../util/app_colors.dart';

class QrCodeHelper {
  static QrImageView createQrImage(String data) {
    return QrImageView(
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

  Future<String> scanQrCode(BuildContext context) async {
    try {
      final completer = Completer<String>();
      
      // Navigate to a full-screen scanner
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Scan QR Code'),
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
            ),
            body: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    Navigator.of(context).pop();
                    completer.complete(barcode.rawValue!);
                    return;
                  }
                }
              },
            ),
          ),
        ),
      );

      return await completer.future;
    } on PlatformException {
      throw Exception('Failed to scan QR code.');
    }
  }
}
