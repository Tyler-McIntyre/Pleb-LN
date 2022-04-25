import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'UI/node_settings.dart';
import 'app_colors.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.width,
    required this.fontSize,
  }) : super(key: key);
  final Function onPressed;
  final Widget icon;
  final Widget label;
  final double width;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onPressed(),
      label: label,
      icon: icon,
      style: ElevatedButton.styleFrom(
        elevation: 3,
        fixedSize: Size(width, double.infinity),
        primary: AppColors.black,
        onPrimary: AppColors.white,
        shadowColor: AppColors.orange,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        textStyle: TextStyle(fontSize: fontSize),
      ),
    );
  }
}

class SquareButton extends StatelessWidget {
  const SquareButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.width,
    required this.height,
    required this.fontSize,
  }) : super(key: key);
  final Function onPressed;
  final Widget icon;
  final Widget label;
  final double width;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onPressed(),
      label: label,
      icon: icon,
      style: ElevatedButton.styleFrom(
        elevation: 3,
        fixedSize: Size(width, height),
        primary: AppColors.black,
        onPrimary: AppColors.white,
        textStyle: TextStyle(fontSize: fontSize),
        side: const BorderSide(color: AppColors.orange, width: 1.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
      ),
    );
  }
}

class LinkNodeButton extends StatelessWidget {
  const LinkNodeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String _logoPath =
        'images/Firebolt-logos/Firebolt-logos-thumbnail.jpeg';

    return AvatarGlow(
      endRadius: 180,
      glowColor: AppColors.red,
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
                  _logoPath,
                  scale: 1,
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NodeSettings(),
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppColors.black),
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
