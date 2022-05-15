import 'package:flutter/material.dart';
import 'UI/home_screen.dart';
import 'util/app_colors.dart';

void main() {
  runApp(const FireBolt());
}

class FireBolt extends StatefulWidget {
  const FireBolt({Key? key}) : super(key: key);

  @override
  State<FireBolt> createState() => _FireBoltState();
}

class _FireBoltState extends State<FireBolt> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.redPrimary,
        colorScheme: ColorScheme(
          background: AppColors.black,
          onPrimary: AppColors.white,
          brightness: Brightness.light,
          error: AppColors.orange,
          onBackground: AppColors.black,
          onError: AppColors.orange,
          onSecondary: AppColors.black,
          onSurface: AppColors.black,
          primary: AppColors.redPrimary,
          secondary: AppColors.redSecondary,
          surface: AppColors.yellow,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
