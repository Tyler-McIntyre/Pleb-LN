import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../util/app_colors.dart';

class QrCodeGenerator extends StatefulWidget {
  const QrCodeGenerator({Key? key}) : super(key: key);

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  @override
  Widget build(BuildContext context) {
    return QrImage(
      data: 'Coming Soon!',
      version: QrVersions.auto,
      size: 270,
      gapless: false,
      backgroundColor: AppColors.white,
    );
  }
}
