import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import '../util/app_assets.dart';
import 'node_config.dart';
import '../util/app_colors.dart';

class LinkNodeButton extends StatelessWidget {
  const LinkNodeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      endRadius: 180,
      glowColor: AppColors.white,
      shape: BoxShape.circle,
      child: SizedBox(
        height: 120,
        width: 120,
        child: TextButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  AppAssets.logoPath,
                  scale: 1,
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NodeConfig(),
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(72.0),
                side: const BorderSide(color: Colors.transparent),
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
