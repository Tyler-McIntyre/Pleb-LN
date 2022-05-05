import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../util/app_colors.dart';

class Activity {
  static List<Tuple5<Icon, String, String, String, String>> listTileInfo =
      const [
    Tuple5(
        Icon(
          Icons.receipt,
          color: AppColors.white,
        ),
        'Received',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.receipt,
          color: AppColors.white,
        ),
        'Received',
        'on-chain',
        '1/28/2022',
        '130,812 sats'),
    Tuple5(
        Icon(
          Icons.receipt,
          color: AppColors.white,
        ),
        'Received',
        'on-chain',
        '12/10/2021',
        '10,000,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
    Tuple5(
        Icon(
          Icons.receipt,
          color: AppColors.white,
        ),
        'Received',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
  ];
}
