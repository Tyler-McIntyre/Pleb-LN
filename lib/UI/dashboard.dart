import 'package:firebolt/UI/node_config.dart';
import 'package:firebolt/UI/receive.dart';
import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import '../models/balance.dart';
import '../database/secure_storage.dart';
import '../models/activity.dart';
import 'curve_clipper.dart';

enum activitySortOptions { DateReceived, SentOnly, ReceivedOnly }

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String balanceShown;
  int balanceIndex = 0;
  bool symbolIsVisable = true;
  late Widget currencySymbolShown;
  bool satsIsVisable = true;
  bool btcIsVisable = false;
  TextEditingController nicknameController = TextEditingController();
  activitySortOptions? _activitySortOption = activitySortOptions.DateReceived;

  updateBalance() {
    //increment the index
    balanceIndex >= Balance.conversions.length - 1
        ? balanceIndex = 0
        : balanceIndex += 1;

    //update the balance shown
    setState(
      () {
        balanceShown = Balance.conversions.values.toList()[balanceIndex];
        currencySymbolShown = Balance.conversions.keys.toList()[balanceIndex];

        if (balanceIndex == 0) {
          satsIsVisable = true;
        } else if (balanceIndex == 1) {
          satsIsVisable = false;
          btcIsVisable = true;
        } else {
          btcIsVisable = false;
        }
      },
    );
  }

  @override
  void initState() {
    balanceShown = Balance.conversions.values.first;
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

  final Map<String, Icon> _tabs = {
    'Off-Chain': const Icon(
      Icons.bolt,
      color: Colors.yellow,
    ),
    'On-Chain': const Icon(
      Icons.currency_bitcoin,
      color: Colors.orange,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Stack(
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
                                              text: balanceShown.toString(),
                                              style:
                                                  const TextStyle(fontSize: 35),
                                              children: [
                                                satsIsVisable
                                                    ? WidgetSpan(
                                                        child:
                                                            currencySymbolShown,
                                                      )
                                                    : const WidgetSpan(
                                                        child:
                                                            SizedBox.shrink(),
                                                      ),
                                              ]),
                                        ],
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 240, 240, 238),
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
                                        color:
                                            Color.fromARGB(255, 240, 240, 238),
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
                            side: const BorderSide(
                                color: AppColors.orange, width: 1.0),
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
          ),
          const Divider(),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: DefaultTabController(
              length: _tabs.length,
              child: Scaffold(
                backgroundColor: Colors.black,
                body: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                        sliver: SliverAppBar(
                          automaticallyImplyLeading: false,
                          actions: [
                            PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                  color: AppColors.orange,
                                ),
                              ),
                              color: AppColors.secondaryBlack,
                              icon: const Icon(Icons.account_balance_wallet),
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  child: ListTile(
                                    tileColor: AppColors.secondaryBlack,
                                    title: Text(
                                      _tabs.keys.first,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    textColor: Colors.white,
                                    trailing: Text.rich(
                                      TextSpan(
                                        text: '1,245,356',
                                        children: [
                                          TextSpan(
                                            text: 'sats',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  child: ListTile(
                                    tileColor: AppColors.secondaryBlack,
                                    title: Text(
                                      _tabs.keys.last,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    textColor: Colors.white,
                                    trailing: Text.rich(
                                      TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: _tabs.values.last,
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '1.01846',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ],
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                const snackBar = SnackBar(
                                  content: Text(
                                    'Coming Soon -> Open a channel.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  backgroundColor: (AppColors.blueSecondary),
                                );

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                            ),
                            PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(color: AppColors.orange),
                              ),
                              color: AppColors.secondaryBlack,
                              icon: const Icon(Icons.filter_alt),
                              onSelected: (String result) {
                                switch (result) {
                                  case 'Date Received':
                                    setState(() {
                                      _activitySortOption =
                                          activitySortOptions.DateReceived;
                                    });
                                    break;
                                  case 'Sent Only':
                                    setState(() {
                                      _activitySortOption =
                                          activitySortOptions.SentOnly;
                                    });
                                    break;
                                  case 'Received Only':
                                    setState(() {
                                      _activitySortOption =
                                          activitySortOptions.ReceivedOnly;
                                    });
                                    break;
                                  default:
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem<String>(
                                  value: 'Date Received',
                                  child: ListTile(
                                    leading: Radio<activitySortOptions>(
                                      fillColor: MaterialStateProperty.all(
                                          AppColors.white),
                                      value: activitySortOptions.DateReceived,
                                      groupValue: _activitySortOption,
                                      onChanged: null,
                                    ),
                                    tileColor: AppColors.secondaryBlack,
                                    textColor: AppColors.white,
                                    title: Text('Date Received'),
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'Sent Only',
                                  child: ListTile(
                                    leading: Radio<activitySortOptions>(
                                      fillColor: MaterialStateProperty.all(
                                          AppColors.white),
                                      value: activitySortOptions.SentOnly,
                                      groupValue: _activitySortOption,
                                      onChanged: null,
                                    ),
                                    tileColor: AppColors.secondaryBlack,
                                    textColor: AppColors.white,
                                    title: Text('Sent Only'),
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'Received Only',
                                  child: ListTile(
                                    leading: Radio<activitySortOptions>(
                                      fillColor: MaterialStateProperty.all(
                                          AppColors.white),
                                      value: activitySortOptions.ReceivedOnly,
                                      groupValue: _activitySortOption,
                                      onChanged: null,
                                    ),
                                    tileColor: AppColors.secondaryBlack,
                                    textColor: AppColors.white,
                                    title: Text('Received Only'),
                                  ),
                                ),
                              ],
                            )
                          ],
                          backgroundColor: AppColors.black,
                          title: const Text('Activity'),
                          pinned: true,
                          forceElevated: innerBoxIsScrolled,
                          bottom: TabBar(
                            tabs: _tabs.entries
                                .map(
                                  (tab) => Tab(
                                    text: tab.key,
                                    icon: tab.value,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: _tabs.entries.map(
                      (tab) {
                        return SafeArea(
                          top: false,
                          bottom: false,
                          child: Builder(
                            builder: (BuildContext context) {
                              return CustomScrollView(
                                key: PageStorageKey<String>(tab.key),
                                slivers: <Widget>[
                                  SliverOverlapInjector(
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(
                                            context),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.all(16.0),
                                    sliver: SliverFixedExtentList(
                                      itemExtent: 500.0,
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          return ListTileTheme(
                                            tileColor: AppColors.secondaryBlack,
                                            textColor: AppColors.white,
                                            child: Scrollbar(
                                              child: ListView.builder(
                                                itemCount: Activity
                                                    .listTileInfo.length,
                                                itemBuilder: (context, index) {
                                                  return Card(
                                                    color: AppColors.blueGrey,
                                                    child: ListTile(
                                                      style: ListTileStyle.list,
                                                      leading: Activity
                                                          .listTileInfo[index]
                                                          .item1,
                                                      title: Text.rich(
                                                        TextSpan(
                                                          text: null,
                                                          children: [
                                                            TextSpan(
                                                              text: Activity
                                                                  .listTileInfo[
                                                                      index]
                                                                  .item2,
                                                              style: const TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .grey,
                                                                  fontSize: 15),
                                                            ),
                                                            WidgetSpan(
                                                              child:
                                                                  Container(),
                                                            ),
                                                            TextSpan(
                                                              text: Activity
                                                                  .listTileInfo[
                                                                      index]
                                                                  .item4,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                            WidgetSpan(
                                                              child:
                                                                  Container(),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      trailing: Text(
                                                        Activity
                                                            .listTileInfo[index]
                                                            .item5,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: (Activity
                                                                      .listTileInfo[
                                                                          index]
                                                                      .item2 ==
                                                                  'Sent'
                                                              ? AppColors.red
                                                              : AppColors
                                                                  .green),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
