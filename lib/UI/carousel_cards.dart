import 'package:firebolt/UI/send_off_chain.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../buttons.dart';
import '../dto/balance.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OffChainCarouselCard extends StatefulWidget {
  const OffChainCarouselCard({Key? key}) : super(key: key);

  @override
  State<OffChainCarouselCard> createState() => _OffChainCarouselCardState();
}

class _OffChainCarouselCardState extends State<OffChainCarouselCard> {
  late String balanceShown;
  int balanceIndex = 0;
  bool symbolIsVisable = true;
  late Widget currencySymbolShown;
  bool satsIsVisable = true;
  bool btcIsVisable = false;

  @override
  // ignore: must_call_super
  void initState() {
    balanceShown = Balance.conversions.values.first;
    currencySymbolShown = Balance.conversions.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.25,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            height: 53,
          ),
          //Title
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Off-Chain',
                ),
                WidgetSpan(
                  child: Icon(
                    Icons.bolt,
                    color: AppColors.yellow,
                    size: 40,
                  ),
                ),
                TextSpan(
                  text: 'Lightning Network',
                  style: TextStyle(color: AppColors.grey, fontSize: 15),
                )
              ],
              style: TextStyle(
                  fontSize: 32.0,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold),
            ),
            textAlign: TextAlign.center,
          ),
          const Divider(
            height: 10,
            thickness: 1,
            color: AppColors.orange,
          ),
          const Divider(),
          Row(
            children: [
              Visibility(
                visible: symbolIsVisable,
                child: currencySymbolShown,
              ),
              Expanded(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        balanceIndex >= Balance.conversions.length - 1
                            ? balanceIndex = 0
                            : balanceIndex += 1;
                        setState(() {
                          balanceShown =
                              Balance.conversions.values.toList()[balanceIndex];
                          currencySymbolShown =
                              Balance.conversions.keys.toList()[balanceIndex];
                        });
                      },
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: balanceShown.toString(),
                              style: const TextStyle(fontSize: 25),
                            ),
                          ],
                          style: const TextStyle(
                            color: Color.fromARGB(255, 240, 240, 238),
                          ),
                        ),
                      ),
                    ),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Tap to convert',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                            ),
                          )
                        ],
                        style: TextStyle(
                          color: Color.fromARGB(255, 240, 240, 238),
                        ),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SquareButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.connect_without_contact,
                        color: AppColors.orange,
                      ),
                      label: const Text('Open Channel'),
                      width: double.infinity,
                      height: double.infinity,
                      fontSize: 14,
                    ),
                    SquareButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.alt_route,
                        color: AppColors.orange,
                      ),
                      label: const Text('Manage Channels'),
                      width: double.infinity,
                      height: double.infinity,
                      fontSize: 14,
                    )
                  ],
                ),
              )
            ],
          ),
          const Divider(
            height: 25,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SquareButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SendWithLightning(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.send,
                  color: AppColors.orange,
                ),
                label: const Text('Send'),
                width: double.infinity,
                height: 50,
                fontSize: 20,
              ),
              const Divider(),
              SquareButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.receipt,
                  color: AppColors.orange,
                ),
                label: const Text('Receive'),
                width: double.infinity,
                height: 50,
                fontSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnChainCarouselCard extends StatefulWidget {
  const OnChainCarouselCard({Key? key}) : super(key: key);

  @override
  State<OnChainCarouselCard> createState() => _OnChainCarouselCardState();
}

class _OnChainCarouselCardState extends State<OnChainCarouselCard> {
  late String balanceShown;
  int balanceIndex = 0;
  bool symbolIsVisable = true;
  late Widget currencySymbolShown;

  @override
  // ignore: must_call_super
  void initState() {
    balanceShown = Balance.conversions.values.first;
    currencySymbolShown = Balance.conversions.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.25,
        height: MediaQuery.of(context).size.height,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Divider(
            height: 53,
          ),
          //Title
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'On-Chain',
                ),
                WidgetSpan(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(
                      children: const [
                        FaIcon(
                          FontAwesomeIcons.link,
                          color: AppColors.orange,
                          size: 30,
                        ),
                        SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                  ),
                ),
                const TextSpan(
                  text: 'Base Network',
                  style: TextStyle(color: AppColors.grey, fontSize: 15),
                )
              ],
              style: const TextStyle(
                fontSize: 32.0,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            textAlign: TextAlign.start,
          ),
          const Divider(
            height: 10,
            thickness: 1,
            color: AppColors.orange,
          ),
          const Divider(),
          Row(
            children: [
              Visibility(
                visible: symbolIsVisable,
                child: currencySymbolShown,
              ),
              Expanded(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        balanceIndex >= Balance.conversions.length - 1
                            ? balanceIndex = 0
                            : balanceIndex += 1;
                        setState(() {
                          balanceShown =
                              Balance.conversions.values.toList()[balanceIndex];
                          currencySymbolShown =
                              Balance.conversions.keys.toList()[balanceIndex];
                        });
                      },
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: balanceShown.toString(),
                              style: const TextStyle(fontSize: 25),
                            ),
                          ],
                          style: const TextStyle(
                            color: Color.fromARGB(255, 240, 240, 238),
                          ),
                        ),
                      ),
                    ),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Tap to convert',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                            ),
                          )
                        ],
                        style: TextStyle(
                          color: Color.fromARGB(255, 240, 240, 238),
                        ),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SquareButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.change_circle_outlined,
                        color: AppColors.orange,
                      ),
                      label: const Text('Mix Coins'),
                      width: double.infinity,
                      height: double.infinity,
                      fontSize: 14,
                    ),
                    SquareButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.transit_enterexit,
                        color: AppColors.orange,
                      ),
                      label: const Text('UTXO'),
                      width: double.infinity,
                      height: double.infinity,
                      fontSize: 14,
                    )
                  ],
                ),
              )
            ],
          ),
          const Divider(
            height: 25,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SquareButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SendWithLightning()),
                  );
                },
                icon: const Icon(
                  Icons.send_outlined,
                  color: AppColors.orange,
                ),
                label: const Text('Send'),
                width: double.infinity,
                height: 50,
                fontSize: 20,
              ),
              const Divider(),
              SquareButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.receipt,
                  color: AppColors.orange,
                ),
                label: const Text('Receive'),
                width: double.infinity,
                height: 50,
                fontSize: 20,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

List<StatefulWidget> carouselCards = [
  const OffChainCarouselCard(),
  const OnChainCarouselCard(),
];
