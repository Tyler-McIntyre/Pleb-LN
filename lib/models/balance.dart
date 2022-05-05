import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';

import '../util/app_colors.dart';

class Balance {
  static int balanceSats = Balance.getOffChainBalance();
  static double balanceBitcoin = Balance.getOffChainBalance() / 10000000;

  //TODO: need to pull current exchange rates {Bitcoin Amount} * {Exchange Rate}
  static double currentBtcExchangeRate = 40000;
  static double balanceDollars = (balanceBitcoin * currentBtcExchangeRate);
  static Map<Widget, String> conversions = {
    const Text.rich(
      TextSpan(
        text: 'sats',
        style: TextStyle(
          color: AppColors.white60,
          fontSize: 22,
        ),
      ),
    ): MoneyFormatter(
      amount: balanceSats.toDouble(),
    ).output.withoutFractionDigits,
    const Icon(
      Icons.currency_bitcoin,
      color: AppColors.orange,
      size: 35,
    ): '$balanceBitcoin',
    const SizedBox():
        (MoneyFormatter(amount: balanceDollars).output.symbolOnLeft)
  };

  static int getOffChainBalance() {
    //TODO: Retrieve off chain balance from node
    int offChainBalance = 1135098;
    return offChainBalance;
  }

  static String getOnChainBalance() {
    //TODO: Retrieve off chain balance from node
    String onChainBalance = '0.138291';
    return onChainBalance;
  }
}
