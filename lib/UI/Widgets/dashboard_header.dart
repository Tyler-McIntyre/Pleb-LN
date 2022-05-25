import 'package:firebolt/UI/create_invoice_screen.dart';
import 'package:firebolt/UI/send_screen.dart';
import 'package:firebolt/models/blockchain_balance.dart';
import 'package:firebolt/api/lnd.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:money_formatter/money_formatter.dart';
import '../../database/secure_storage.dart';
import '../../util/app_colors.dart';
import 'curve_clipper.dart';
import '../node_config_screen.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({
    required this.nodeIsConfigured,
    required this.isExpanded,
    Key? key,
  }) : super(key: key);
  final bool nodeIsConfigured;
  final bool isExpanded;

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

    if (widget.nodeIsConfigured == true) {
      setState(() {
        nicknameController.text = nickname;
      });
    }
  }

  Future<BlockchainBalance> _nodeBalance() async {
    BlockchainBalance result;
    if (widget.nodeIsConfigured) {
      LND api = LND();
      //TODO: Fetch the current exchange rate
      double currentBtcExchangeRate = 40000;
      result = await api.getBlockchainBalance();
      String totalBalance = result.totalBalance;
      balanceWidgets = [
        Text.rich(
          TextSpan(
              text: MoneyFormatter(
                amount: int.parse(totalBalance).toDouble(),
              ).output.withoutFractionDigits,
              children: [
                TextSpan(
                    text: 'sats',
                    style: Theme.of(context).textTheme.titleMedium),
              ]),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        //balance in sats / 10000000
        Text.rich(
          TextSpan(children: [
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Icon(
                  Icons.currency_bitcoin,
                  color: AppColors.orange,
                  size: 45,
                ),
              ),
            ),
            TextSpan(text: '${(int.parse(totalBalance) / 10000000)}'),
          ]),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        //balance in bitcoin / the current exchange rate
        Text(
          (MoneyFormatter(
                  amount: ((int.parse(totalBalance) / 10000000) *
                      currentBtcExchangeRate))
              .output
              .symbolOnLeft),
          style: Theme.of(context).textTheme.titleLarge,
        )
      ];
    } else {
      result = BlockchainBalance('0', null, null, null);
      balanceWidgets = [
        Text.rich(
            TextSpan(
                text: MoneyFormatter(
                  amount: int.parse(result.totalBalance).toDouble(),
                ).output.withoutFractionDigits,
                children: [
                  TextSpan(
                      text: 'sats',
                      style: Theme.of(context).textTheme.titleMedium),
                ]),
            style: Theme.of(context).textTheme.titleLarge),
      ];
    }

    return result;
  }

  RangeValues balanceContainerRanges = RangeValues(.23, .77);
  RangeValues buttonContainerRanges = RangeValues(.18, .72);
  int containerAnimationSpeed = 400;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: CurveClipper(),
          child: AnimatedContainer(
            height: widget.isExpanded
                ? MediaQuery.of(context).size.height *
                    balanceContainerRanges.start
                : MediaQuery.of(context).size.height *
                    balanceContainerRanges.end,
            color: AppColors.black,
            duration: Duration(milliseconds: containerAnimationSpeed),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<BlockchainBalance>(
                  future: _nodeBalance(),
                  builder: (BuildContext context,
                      AsyncSnapshot<BlockchainBalance> snapshot) {
                    List<Widget> children;
                    if (snapshot.hasData) {
                      children = [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _changeBalanceWidget();
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                nicknameController.text,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              balanceWidgets[balanceWidgetIndex],
                            ],
                          ),
                        ),
                      ];
                    } else if (snapshot.hasError) {
                      children = <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 1.25,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(
                                      color: Theme.of(context).errorColor),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        )
                      ];
                    } else {
                      children = const <Widget>[
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        ),
                      ];
                    }
                    return SizedBox(
                      height: 135,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: children,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(
              top: widget.isExpanded
                  ? MediaQuery.of(context).size.height *
                      buttonContainerRanges.start
                  : MediaQuery.of(context).size.height *
                      buttonContainerRanges.end,
              right: 20.0,
              left: 20.0),
          duration: Duration(milliseconds: containerAnimationSpeed),
          child: SizedBox(
            height: 65.0,
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _dashboardButtonBar(),
              ),
            ),
          ),
        )
      ],
    );
  }

  _dashboardButtonBar() {
    return [
      TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SendScreen(),
              ));
        },
        style: ElevatedButton.styleFrom(
          elevation: 3,
          fixedSize: const Size(100, 71),
          primary: AppColors.black,
          onPrimary: AppColors.white,
          textStyle: Theme.of(context).textTheme.displaySmall,
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
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            Text(
              'Pay',
            ),
          ],
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateInvoiceScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 3,
          fixedSize: const Size(100, 71),
          primary: AppColors.black,
          textStyle: Theme.of(context).textTheme.displaySmall,
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
          children: [
            Icon(Icons.receipt_outlined,
                color: Theme.of(context).colorScheme.onPrimary),
            Text(
              'Receive',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
          textStyle: Theme.of(context).textTheme.displaySmall,
          side: const BorderSide(color: AppColors.orange, width: 1.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.raspberryPi,
              color: Colors.white,
            ),
            Text('Node',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary))
          ],
        ),
      )
    ];
  }

  void _changeBalanceWidget() {
    balanceWidgetIndex >= balanceWidgets.length - 1
        ? balanceWidgetIndex = 0
        : balanceWidgetIndex += 1;
  }
}
