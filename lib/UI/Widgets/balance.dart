import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';

import '../../rest/coin_gecko.dart';

class Balance {
  static Future<List<Widget>> buildWidgets(
      String amt, BuildContext context) async {
    double usdToBtcRate = await CoinGecko.fetchBtcExchangeRate();
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
        (MoneyFormatter(amount: ((int.parse(amt) / 10000000) * usdToBtcRate))
            .output
            .symbolOnLeft),
        style: Theme.of(context).textTheme.bodyLarge,
      )
    ];
  }
}
