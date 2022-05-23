import 'dart:io';
import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        textTheme: TextTheme(
          titleLarge: TextStyle(color: AppColors.white, fontSize: 45),
          titleMedium: TextStyle(color: AppColors.white60, fontSize: 34),
          titleSmall: TextStyle(color: AppColors.white70, fontSize: 26),
          displayLarge: TextStyle(color: AppColors.white, fontSize: 32),
          displayMedium: TextStyle(color: AppColors.grey, fontSize: 23),
          displaySmall: TextStyle(color: AppColors.grey, fontSize: 21),
        ),
        listTileTheme: ListTileThemeData(
            tileColor: AppColors.blackSecondary,
            textColor: AppColors.white,
            iconColor: AppColors.white),
        errorColor: AppColors.red,
        fontFamily: GoogleFonts.bebasNeue().fontFamily,
        scaffoldBackgroundColor: AppColors.blue,
        colorScheme: ColorScheme(
          background: AppColors.black,
          onPrimary: AppColors.white,
          brightness: Brightness.light,
          error: AppColors.orange,
          onBackground: AppColors.black,
          onError: AppColors.orange,
          onSecondary: AppColors.black,
          onSurface: AppColors.white,
          primary: AppColors.white,
          secondary: AppColors.redSecondary,
          surface: AppColors.orange,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
