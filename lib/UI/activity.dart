import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../app_colors.dart';

class Activity extends StatelessWidget {
  const Activity({Key? key}) : super(key: key);

  final List<Tuple5<Icon, String, String, String, String>> listTileInfo =
      const [
    Tuple5(
        Icon(
          Icons.bolt,
          color: AppColors.yellow,
        ),
        'Received',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.bolt,
          color: AppColors.yellow,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.currency_bitcoin,
          color: AppColors.orange,
        ),
        'Received',
        'on-chain',
        '1/28/2022',
        '130,812 sats'),
    Tuple5(
        Icon(
          Icons.currency_bitcoin,
          color: AppColors.orange,
        ),
        'Received',
        'on-chain',
        '12/10/2021',
        '10,000,000 sats'),
    Tuple5(
        Icon(
          Icons.currency_bitcoin,
          color: AppColors.orange,
        ),
        'Sent',
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
    Tuple5(
        Icon(
          Icons.bolt,
          color: AppColors.yellow,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.bolt,
          color: AppColors.yellow,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.bolt,
          color: AppColors.yellow,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.currency_bitcoin,
          color: AppColors.orange,
        ),
        'Sent',
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
    Tuple5(
        Icon(
          Icons.bolt,
          color: AppColors.yellow,
        ),
        'Received',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.currency_bitcoin,
          color: AppColors.orange,
        ),
        'Sent',
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          width: MediaQuery.of(context).size.width / 1.2,
          child: ListTileTheme(
            tileColor: AppColors.secondaryBlack,
            textColor: AppColors.white,
            iconColor: AppColors.white,
            child: ListView.builder(
              itemCount: listTileInfo.length,
              itemBuilder: (context, index) {
                return Card(
                  color: AppColors.blueGrey,
                  child: ListTile(
                    leading: listTileInfo[index].item1,
                    title: Text.rich(
                      TextSpan(
                        text: null,
                        children: [
                          TextSpan(
                            text: listTileInfo[index].item2,
                            style: const TextStyle(
                                color: AppColors.grey, fontSize: 15),
                          ),
                          WidgetSpan(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            ),
                          ),
                          TextSpan(
                            text: listTileInfo[index].item4,
                            style: const TextStyle(fontSize: 15),
                          ),
                          WidgetSpan(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            ),
                          ),
                          TextSpan(
                            text: listTileInfo[index].item3,
                            style: const TextStyle(
                                color: AppColors.grey, fontSize: 15),
                          )
                        ],
                      ),
                    ),
                    trailing: Text(
                      listTileInfo[index].item5,
                      style: TextStyle(
                        fontSize: 16,
                        color: (listTileInfo[index].item2 == 'Sent'
                            ? AppColors.red
                            : AppColors.green),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
