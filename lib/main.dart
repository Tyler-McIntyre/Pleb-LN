import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../UI/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/app_initializer.dart';
import 'util/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: const PlebLN()));
}

class PlebLN extends ConsumerStatefulWidget {
  const PlebLN({Key? key}) : super(key: key);

  @override
  ConsumerState<PlebLN> createState() => _PlebLNState();
}

class _PlebLNState extends ConsumerState<PlebLN> {
  @override
  void initState() {
    super.initState();
    AppInitializer.initialize(ref);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
              color: AppColors.white,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.white,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.blue,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppColors.white,
            selectionHandleColor: AppColors.blue,
          ),
          textTheme: TextTheme(
            labelSmall: TextStyle(color: AppColors.grey, fontSize: 17),
            labelMedium: TextStyle(
                color: AppColors.white, fontSize: 17, letterSpacing: 2),
            displaySmall: TextStyle(color: AppColors.white, fontSize: 18),
            displayMedium: TextStyle(color: AppColors.white, fontSize: 20),
            displayLarge: TextStyle(color: AppColors.white, fontSize: 22),
            bodySmall: TextStyle(color: AppColors.white, fontSize: 18),
            bodyMedium: TextStyle(color: AppColors.black, fontSize: 20),
            bodyLarge: TextStyle(color: AppColors.white, fontSize: 26),
          ),
          listTileTheme: ListTileThemeData(
            tileColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          ),
          colorScheme: ColorScheme(
            background: AppColors.black,
            brightness: Brightness.dark,
            error: AppColors.red,
            onBackground: AppColors.black2,
            onError: AppColors.white,
            onPrimary: AppColors.white,
            onSecondary: AppColors.white,
            onSurface: AppColors.white,
            primary: AppColors.black2,
            secondary: AppColors.black2,
            surface: AppColors.white,
          ),
          dialogTheme: DialogTheme(
            backgroundColor: AppColors.white,
            contentTextStyle: TextStyle(
              fontSize: 20,
              color: AppColors.black,
            ),
          ),
          fontFamily: GoogleFonts.lato().fontFamily,
          scaffoldBackgroundColor: AppColors.black,
          appBarTheme: AppBarTheme(backgroundColor: AppColors.black),
          cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
            primaryColor: AppColors.blue,
          )),
      home: DashboardScreen(),
    );
  }
}
