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
        'on-chain',
        '6/19/2021',
        '10,367 sats'),
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
      color: AppColors.yellow,
    ),
    'On-Chain': const Icon(
      Icons.currency_bitcoin,
      color: AppColors.orange,
    ),
  };
  activitySortOptions? _activitySortOption = activitySortOptions.DateReceived;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          backgroundColor: AppColors.black,
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    automaticallyImplyLeading: false,
                    actions: _actionsButtonBar(),
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
              children: _tabViews(),
            ),
          ),
        ),
      ),
    );
  }

  _tabViews() {
    return _tabs.entries.map(
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
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 3),
                    sliver: SliverFixedExtentList(
                      itemExtent: 1000,
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
                                      leading: activityTileInfo[index].item1,
                                      title: Text.rich(
                                        TextSpan(
                                          text: null,
                                          children: [
                                            TextSpan(
                                              text:
                                                  activityTileInfo[index].item2,
                                              style: const TextStyle(
                                                  color: AppColors.grey,
                                                  fontSize: 15),
                                            ),
                                            WidgetSpan(
                                              child: Container(),
                                            ),
                                            TextSpan(
                                              text:
                                                  activityTileInfo[index].item4,
                                              style:
                                                  const TextStyle(fontSize: 15),
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
                                              (activityTileInfo[index].item2 ==
                                                      'Sent'
                                                  ? AppColors.redPrimary
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
    ).toList();
  }

  _actionsButtonBar() {
    return [
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
                _activitySortOption = activitySortOptions.DateReceived;
              });
              break;
            case 'Sent Only':
              setState(() {
                _activitySortOption = activitySortOptions.SentOnly;
              });
              break;
            case 'Received Only':
              setState(() {
                _activitySortOption = activitySortOptions.ReceivedOnly;
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
                fillColor: MaterialStateProperty.all(AppColors.white),
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
                fillColor: MaterialStateProperty.all(AppColors.white),
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
                fillColor: MaterialStateProperty.all(AppColors.white),
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
    ];
  }
}
