import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../util/app_assets.dart';
import '../node_config_screen.dart';
import '../../util/app_colors.dart';

class LinkNodeButton extends StatelessWidget {
  const LinkNodeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      endRadius: 180,
      showTwoGlows: false,
      glowColor: AppColors.white,
      shape: BoxShape.circle,
      child: SizedBox(
        height: 120,
        width: 120,
        child: TextButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.raspberryPi,
                color: AppColors.white,
                size: 100,
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
