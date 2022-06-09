import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_formatter/money_formatter.dart';
import '../../provider/coin_gecko_provider.dart';

class Balance {
  static List<Widget> buildWidgets(
      String amt, BuildContext context, WidgetRef ref) {
    List<Widget> balanceWidgets = [];
    if (amt.isNotEmpty) {
      balanceWidgets.add(Text.rich(
        TextSpan(
            text: MoneyFormatter(
              amount: int.parse(amt).toDouble(),
            ).output.withoutFractionDigits,
            children: [
              TextSpan(
                  text: 'sats', style: Theme.of(context).textTheme.labelSmall),
            ],
            style: Theme.of(context).textTheme.bodyLarge),
      ));
      balanceWidgets.add(
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
              //btc balance = balance in sats / 10000000
              TextSpan(
                text: '${(int.parse(amt) / 10000000)}',
              ),
            ],
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    try {
      bool successResponse =
          ref.watch(CoinGeckoProvider.serverStatus).value ?? false;
      if (successResponse) {
        double? usdToBtcRate = ref.watch(CoinGeckoProvider.usdToBtcRate).value;
        if (usdToBtcRate != null) {
          balanceWidgets.add(
            Text(
              //balance in USD = balance in bitcoin / the current exchange rate
              (MoneyFormatter(
                      amount: ((int.parse(amt) / 10000000) * usdToBtcRate))
                  .output
                  .symbolOnLeft),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
      }
    } catch (ex) {
      //Do nothing
    }

    return balanceWidgets;
  }
}
