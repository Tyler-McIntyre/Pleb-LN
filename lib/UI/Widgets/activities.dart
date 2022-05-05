import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../../util/app_colors.dart';

enum activitySortOptions { DateReceived, SentOnly, ReceivedOnly }

class Activities extends StatefulWidget {
  const Activities({Key? key}) : super(key: key);

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  List<Tuple5<Icon, String, String, String, String>> activityTileInfo = const [
    Tuple5(
        Icon(
          Icons.receipt,
          color: AppColors.white,
        ),
        'Received',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.receipt,
          color: AppColors.white,
        ),
        'Received',
        'on-chain',
        '1/28/2022',
        '130,812 sats'),
    Tuple5(
        Icon(
          Icons.receipt,
          color: AppColors.white,
        ),
        'Received',
        'on-chain',
        '12/10/2021',
        '10,000,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
    Tuple5(
        Icon(
          Icons.receipt,
          color: AppColors.white,
        ),
        'Received',
        'off-chain',
        '4/10/2022',
        '10,000 sats'),
    Tuple5(
        Icon(
          Icons.send,
          color: AppColors.white,
        ),
        'Sent',
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
  ];
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
  activitySortOptions? _activitySortOption = activitySortOptions.DateReceived;

  @override
  Widget build(BuildContext context) {
    return //*Activity Section
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
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                                fillColor:
                                    MaterialStateProperty.all(AppColors.white),
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
                                fillColor:
                                    MaterialStateProperty.all(AppColors.white),
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
                                fillColor:
                                    MaterialStateProperty.all(AppColors.white),
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
                                  .sliverOverlapAbsorberHandleFor(context),
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
                                          itemCount: activityTileInfo.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                              color: AppColors.blueGrey,
                                              child: ListTile(
                                                style: ListTileStyle.list,
                                                leading: activityTileInfo[index]
                                                    .item1,
                                                title: Text.rich(
                                                  TextSpan(
                                                    text: null,
                                                    children: [
                                                      TextSpan(
                                                        text: activityTileInfo[
                                                                index]
                                                            .item2,
                                                        style: const TextStyle(
                                                            color:
                                                                AppColors.grey,
                                                            fontSize: 15),
                                                      ),
                                                      WidgetSpan(
                                                        child: Container(),
                                                      ),
                                                      TextSpan(
                                                        text: activityTileInfo[
                                                                index]
                                                            .item4,
                                                        style: const TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      WidgetSpan(
                                                        child: Container(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                trailing: Text(
                                                  activityTileInfo[index].item5,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        (activityTileInfo[index]
                                                                    .item2 ==
                                                                'Sent'
                                                            ? AppColors.red
                                                            : AppColors.green),
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
    );
  }
}
