import 'package:flutter/material.dart';
import '../../util/app_assets.dart';
import '../node_config_screen.dart';
import '../../util/app_colors.dart';

class LinkNodeButton extends StatelessWidget {
  const LinkNodeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: TextButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/Pleb-logos_round.png',
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NodeConfigScreen(),
            ),
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(72.0),
              side: const BorderSide(color: AppColors.transparent),
            ),
          ),
        ),
      ),
    );
  }
}

class AppBarIconButton extends StatelessWidget {
  const AppBarIconButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.maybePop(
        context,
      ),
      icon: Image.asset(
        AppAssets.logoPath,
      ),
    );
  }
}
