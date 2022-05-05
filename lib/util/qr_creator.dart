import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCreator extends StatefulWidget {
  const QRCreator({Key? key}) : super(key: key);

  @override
  State<QRCreator> createState() => _QRCreatorState();
}

class _QRCreatorState extends State<QRCreator> {
  @override
  Widget build(BuildContext context) {
    return QrImage(
      data: 'Coming Soon!',
      version: QrVersions.auto,
      size: 270,
      gapless: false,
      backgroundColor: Colors.white,
    );
  }
}
