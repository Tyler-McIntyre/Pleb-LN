import 'package:firebolt/UI/receive_screen.dart';
import 'package:firebolt/models/channel_balance.dart';
import 'package:firebolt/util/restapi.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import '../../database/secure_storage.dart';
import '../../util/app_colors.dart';
import 'curve_clipper.dart';
import '../node_config_screen.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({Key? key}) : super(key: key);

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  late List<Widget> balanceWidgets;
  static int balanceWidgetIndex = 0;
  TextEditingController nicknameController = TextEditingController();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    final String nickname = await SecureStorage.readValue('nickname') ?? '';

    setState(() {
      nicknameController.text = nickname;
    });
  }

  Future<ChannelBalance> _nodeBalance() async {
    RestApi api = RestApi();
    //TODO: Fetch the current exchange rate
    double currentBtcExchangeRate = 40000;
    ChannelBalance result = await api.getLightningBalance();
    balanceWidgets = [
      Text.rich(
        TextSpan(
            text: MoneyFormatter(
              amount: int.parse(result.balance).toDouble(),
            ).output.withoutFractionDigits,
            children: [
              TextSpan(
                text: 'sats',
                style: TextStyle(
                  color: AppColors.white60,
                  fontSize: 32,
                ),
              ),
            ]),
        style: TextStyle(color: AppColors.white, fontSize: 36),
      ),
      //balance in sats / 10000000
      Text.rich(
        TextSpan(children: [
          WidgetSpan(
            child: Icon(
              Icons.currency_bitcoin,
              color: AppColors.orange,
              size: 43,
            ),
          ),
          TextSpan(text: '${(int.parse(result.balance) / 10000000)}'),
        ]),
        style: TextStyle(color: AppColors.white, fontSize: 36),
      ),
      //balance in bitcoin / the current exchange rate
      Text(
        (MoneyFormatter(
                amount: ((int.parse(result.balance) / 10000000) *
                    currentBtcExchangeRate))
            .output
            .symbolOnLeft),
        style: TextStyle(color: AppColors.white, fontSize: 36),
      )
    ];

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            height: MediaQuery.of(context).size.height * .35,
            color: AppColors.black,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      nicknameController.text,
                      style: const TextStyle(
                        color: AppColors.white70,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<ChannelBalance>(
                          future: _nodeBalance(),
                          builder: (BuildContext context,
                              AsyncSnapshot<ChannelBalance> snapshot) {
                            List<Widget> children;
                            if (snapshot.hasData) {
                              children = [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      print(balanceWidgetIndex);
                                      balanceWidgetIndex >=
                                              balanceWidgets.length - 1
                                          ? balanceWidgetIndex = 0
                                          : balanceWidgetIndex += 1;
                                    });
                                  },
                                  child: balanceWidgets[balanceWidgetIndex],
                                ),
                                Text(
                                  'Tap to convert',
                                  style: TextStyle(
                                      color: AppColors.grey, fontSize: 20),
                                ),
                              ];
                            } else if (snapshot.hasError) {
                              children = <Widget>[
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text('Error: ${snapshot.error}'),
                                )
                              ];
                            } else {
                              children = const <Widget>[
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text('Awaiting result...'),
                                )
                              ];
                            }
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: children,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .28,
              right: 20.0,
              left: 20.0),
          child: SizedBox(
            height: 100.0,
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      //TODO: add the QR scanner function
                      const snackBar = SnackBar(
                        content: Text(
                          'Coming Soon -> Open a channel.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                        backgroundColor: (AppColors.blueSecondary),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      fixedSize: const Size(100, 71),
                      primary: AppColors.black,
                      onPrimary: AppColors.white,
                      textStyle: const TextStyle(fontSize: 20),
                      side: const BorderSide(
                        color: AppColors.green,
                        width: 1.0,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.send,
                          color: AppColors.white,
                        ),
                        Text(
                          'Send',
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReceiveScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      fixedSize: const Size(100, 71),
                      primary: AppColors.black,
                      onPrimary: AppColors.white,
                      textStyle: const TextStyle(fontSize: 20),
                      side: const BorderSide(
                        color: AppColors.blueSecondary,
                        width: 1.0,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.receipt,
                          color: AppColors.white,
                        ),
                        Text(
                          'Receive',
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NodeConfigScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      fixedSize: const Size(100, 71),
                      primary: AppColors.black,
                      onPrimary: AppColors.white,
                      textStyle: const TextStyle(fontSize: 20),
                      side:
                          const BorderSide(color: AppColors.orange, width: 1.0),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.computer,
                          color: AppColors.white,
                        ),
                        Text(
                          'Node',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
