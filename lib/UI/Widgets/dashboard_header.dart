import 'package:firebolt/UI/receive.dart';
import 'package:flutter/material.dart';
import '../../database/secure_storage.dart';
import '../../models/balance.dart';
import '../../util/app_colors.dart';
import 'curve_clipper.dart';
import '../node_config.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({Key? key}) : super(key: key);

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  int balanceIndex = 0;
  late String balanceTotal;
  late Widget currencySymbolShown;
  bool symbolIsVisable = true;
  bool satsIsVisable = true;
  bool btcIsVisable = false;
  TextEditingController nicknameController = TextEditingController();
  //Default Sorting option

  updateBalance() {
    //increment the index
    balanceIndex >= Balance.conversions.length - 1
        ? balanceIndex = 0
        : balanceIndex += 1;

    //update the balance shown
    setState(
      () {
        balanceTotal = Balance.conversions.values.toList()[balanceIndex];
        currencySymbolShown = Balance.conversions.keys.toList()[balanceIndex];

        switch (balanceIndex) {
          case 0:
            {
              satsIsVisable = true;
            }
            break;
          case 1:
            {
              satsIsVisable = false;
              btcIsVisable = true;
            }
            break;
          default:
            {
              btcIsVisable = false;
            }
            break;
        }
      },
    );
  }

  @override
  void initState() {
    balanceTotal = Balance.conversions.values.first;
    currencySymbolShown = Balance.conversions.keys.first;
    init();
    super.initState();
  }

  init() async {
    final String nickname = await SecureStorage.readValue('nickname') ?? '';

    setState(() {
      nicknameController.text = nickname;
    });
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      nicknameController.text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            TextButton(
                              onPressed: updateBalance,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    btcIsVisable
                                        ? WidgetSpan(
                                            child: currencySymbolShown,
                                          )
                                        : const WidgetSpan(
                                            child: SizedBox.shrink(),
                                          ),
                                    TextSpan(
                                        text: balanceTotal.toString(),
                                        style: const TextStyle(fontSize: 35),
                                        children: [
                                          satsIsVisable
                                              ? WidgetSpan(
                                                  child: currencySymbolShown,
                                                )
                                              : const WidgetSpan(
                                                  child: SizedBox.shrink(),
                                                ),
                                        ]),
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
                                      color: Colors.white60,
                                      fontSize: 19,
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
                            color: Colors.white,
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
                          builder: (context) => const Receive(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      fixedSize: const Size(100, 71),
                      primary: Colors.black,
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
                            color: Colors.white,
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
                          builder: (context) => const NodeConfig(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      fixedSize: const Size(100, 71),
                      primary: Colors.black,
                      onPrimary: Colors.white,
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
                            color: Colors.white,
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
