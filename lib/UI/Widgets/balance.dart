import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';

class Balance {
  static double currentBtcExchangeRate = 40000;

  static List<Widget> buildWidgets(String amt, BuildContext context) {
    return [
      Text.rich(
        TextSpan(
            text: MoneyFormatter(
              amount: int.parse(amt).toDouble(),
            ).output.withoutFractionDigits,
            children: [
              TextSpan(
                  text: 'sats', style: Theme.of(context).textTheme.labelSmall),
            ],
            style: Theme.of(context).textTheme.bodyLarge),
      ),
      //balance in sats / 10000000
      Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(
                  Icons.currency_bitcoin,
                  color: Colors.orange,
                  size: 30,
                ),
              ),
            ),
            TextSpan(
              text: '${(int.parse(amt) / 10000000)}',
            ),
          ],
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      //balance in bitcoin / the current exchange rate
      Text(
        (MoneyFormatter(
                amount: ((int.parse(amt) / 10000000) * currentBtcExchangeRate))
            .output
            .symbolOnLeft),
        style: Theme.of(context).textTheme.bodyLarge,
      )
    ];
  }
}
