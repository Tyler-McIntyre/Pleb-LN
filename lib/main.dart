import 'dart:io';
import 'package:flutter/material.dart';
import 'UI/home_screen.dart';
import 'util/app_colors.dart';
import 'util/my_http_overrides .dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.orange,
        colorScheme: ColorScheme(
          background: AppColors.black,
          onPrimary: AppColors.white,
          brightness: Brightness.light,
          error: AppColors.orange,
          onBackground: AppColors.black,
          onError: AppColors.orange,
          onSecondary: AppColors.black,
          onSurface: AppColors.white,
          primary: AppColors.orange,
          secondary: AppColors.redSecondary,
          surface: AppColors.orange,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
