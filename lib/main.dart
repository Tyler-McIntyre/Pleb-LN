import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'util/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
          textSelectionTheme:
              TextSelectionThemeData(cursorColor: AppColors.white),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.orange)),
            hintStyle: TextStyle(color: AppColors.grey, fontSize: 22),
            labelStyle: TextStyle(color: AppColors.greySecondary, fontSize: 25),
            errorStyle: TextStyle(fontSize: 19),
          ),
          textTheme: TextTheme(
            labelSmall: TextStyle(color: AppColors.white, fontSize: 18),
            titleLarge: TextStyle(color: AppColors.white, fontSize: 45),
            titleMedium: TextStyle(color: AppColors.white60, fontSize: 34),
            titleSmall: TextStyle(color: AppColors.white70, fontSize: 26),
            displayLarge: TextStyle(color: AppColors.white, fontSize: 32),
            displayMedium:
                TextStyle(color: AppColors.greySecondary, fontSize: 23),
            displaySmall: TextStyle(color: AppColors.grey, fontSize: 21),
            headlineSmall: TextStyle(color: AppColors.grey, fontSize: 20),
            bodyLarge: TextStyle(color: AppColors.white, fontSize: 36),
            bodyMedium: TextStyle(color: AppColors.white, fontSize: 26),
            bodySmall: TextStyle(color: AppColors.white, fontSize: 22),
          ),
          listTileTheme: ListTileThemeData(
              style: ListTileStyle.list,
              tileColor: AppColors.blackSecondary,
              textColor: AppColors.white,
              iconColor: AppColors.white),
          errorColor: AppColors.red,
          fontFamily: GoogleFonts.bebasNeue().fontFamily,
          scaffoldBackgroundColor: AppColors.blue,
          colorScheme: ColorScheme(
            secondaryContainer: AppColors.greySecondary,
            background: AppColors.black,
            onPrimary: AppColors.white,
            brightness: Brightness.light,
            error: AppColors.red,
            onBackground: AppColors.black,
            onError: AppColors.white,
            onSecondary: AppColors.black,
            onSurface: AppColors.white,
            primary: AppColors.blue,
            secondary: AppColors.redSecondary,
            surface: AppColors.white,
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.blackSecondary,
          )),
      home: const DashboardScreen(),
    );
  }
}
