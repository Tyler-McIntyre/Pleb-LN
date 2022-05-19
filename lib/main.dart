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
          error: Color(0xffF75C03),
          onBackground: AppColors.black,
          onError: Color(0xffF75C03),
          onSecondary: AppColors.black,
          onSurface: Color(0xffF3F3F4),
          primary: Color(0xffF75C03),
          secondary: AppColors.redSecondary,
          surface: Color(0xffF75C03),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
