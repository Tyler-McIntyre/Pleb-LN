import 'package:firebolt/models/payment_response.dart';
import 'package:firebolt/util/formatting.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../../api/lnd.dart';
import '../../models/invoice.dart';
import '../../models/invoices.dart';
import '../../models/payments.dart';
import '../../util/app_colors.dart';

enum activitySortOptions { DateReceived, SentOnly, ReceivedOnly }

class Activities extends StatefulWidget {
  const Activities({Key? key}) : super(key: key);

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  activitySortOptions? _activitySortOption = activitySortOptions.DateReceived;
  List<Tuple5<Icon, String, String, DateTime, String>> offChainTxHistory = [];
  //TODO: create the onChainTxHistory list
  List<Widget> _activityCardList = [];
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

  Future<List<Tuple5<Icon, String, String, DateTime, String>>>
      _getTransactions() async {
    List<Tuple5<Icon, String, String, DateTime, String>> offChainTxHistory =
        await _buildOffChainTxList();

    //build the on chain tx list

    //sort both by date
    offChainTxHistory.sort((a, b) {
      return b.item4.compareTo(a.item4);
    });

    setState(() {
      this.offChainTxHistory = offChainTxHistory;
    });

    //combine the two lists and return
    return offChainTxHistory;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                    padding: const EdgeInsets.only(top: 0),
                    sliver: SliverFixedExtentList(
                      itemExtent: 290,
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return ListTileTheme(
                            tileColor: AppColors.blackSecondary,
                            textColor: AppColors.white,
                            child: FutureBuilder(
                              future: _getTransactions(),
                              builder: (
                                context,
                                AsyncSnapshot<
                                        List<
                                            Tuple5<Icon, String, String,
                                                DateTime, String>>>
                                    snapshot,
                              ) {
                                List<Widget> children = [];
                                if (snapshot.hasData) {
                                  if (_activityCardList.isEmpty) {
                                    _activityCardList =
                                        _buildActivityCards(offChainTxHistory);
                                  }
                                  children = _activityCardList;
                                } else if (snapshot.hasError) {
                                  children = <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.25,
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 16),
                                            child: Text(
                                              'Error: ${snapshot.error}',
                                              style: TextStyle(
                                                  color: AppColors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ];
                                } else {
                                  children = <Widget>[
                                    Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 50.0),
                                          child: SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ];
                                }
                                return MediaQuery.removePadding(
                                    removeTop: true,
                                    context: context,
                                    child: Scrollbar(
                                      child: ListView(
                                        padding: EdgeInsets.all(0),
                                        children: children,
                                      ),
                                    ));
                              },
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

  _buildActivityCards(
      List<Tuple5<Icon, String, String, DateTime, String>> txHistory) {
    List<Card> txCardList = [];

    for (Tuple5<Icon, String, String, DateTime, String> tx in txHistory) {
      txCardList.add(
        Card(
          color: AppColors.blueGrey,
          child: ListTile(
            style: ListTileStyle.list,
            leading: tx.item1, //Icon
            title: Text.rich(
              TextSpan(
                text: null,
                children: [
                  TextSpan(
                    text: tx.item2, //sent/received
                    style: const TextStyle(color: AppColors.grey, fontSize: 15),
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                  TextSpan(
                    text: Formatting.dateTimeToShortDate(tx.item4), //date
                    style: const TextStyle(fontSize: 15),
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                ],
              ),
            ),
            trailing: Text(
              tx.item5, //amount
              style: TextStyle(
                fontSize: 16,
                color: (tx.item2 == 'Sent' ? AppColors.red : AppColors.green),
              ),
            ),
          ),
        ),
      );
    }

    return txCardList;
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
        color: AppColors.blackSecondary,
        icon: const Icon(Icons.filter_alt),
        onSelected: (String result) {
          switch (result) {
            case 'Date Received':
              setState(() {
                _activitySortOption = activitySortOptions.DateReceived;
                _activityCardList = _buildActivityCards(offChainTxHistory);
              });
              break;
            case 'Sent Only':
              setState(() {
                _activitySortOption = activitySortOptions.SentOnly;
                _activityCardList = _buildActivityCards(offChainTxHistory
                    .where((element) => element.item2.toLowerCase() == 'sent')
                    .toList());
              });
              break;
            case 'Received Only':
              setState(() {
                _activitySortOption = activitySortOptions.ReceivedOnly;
                _activityCardList = _buildActivityCards(offChainTxHistory
                    .where(
                        (element) => element.item2.toLowerCase() == 'received')
                    .toList());
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
              tileColor: AppColors.blackSecondary,
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
              tileColor: AppColors.blackSecondary,
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
              tileColor: AppColors.blackSecondary,
              textColor: AppColors.white,
              title: Text('Received Only'),
            ),
          ),
        ],
      )
    ];
  }

  _buildOffChainTxList() async {
    List<Tuple5<Icon, String, String, DateTime, String>> allOffChainTxHistory =
        [];
    LND api = LND();
    Payments payments = await api.getPayments();
    for (PaymentResponse payment in payments.payments) {
      DateTime sentDateTime = Formatting.timestampNanoSecondsToDate(
          int.parse(payment.creationTimeNanoSeconds));

      allOffChainTxHistory.add(
        Tuple5(
            Icon(
              Icons.send,
              color: AppColors.white,
            ),
            'Sent',
            'off-chain',
            sentDateTime,
            '${payment.valueSat} sats'),
      );
    }

    Invoices invoices = await api.getInvoices();
    for (Invoice invoice in invoices.invoices) {
      DateTime receivedDateTime =
          Formatting.timestampToDateTime(int.parse(invoice.settleDate));

      if (invoice.settleDate != '0') {
        allOffChainTxHistory.add(
          Tuple5(
              Icon(
                Icons.receipt,
                color: AppColors.white,
              ),
              'Received',
              'off-chain',
              receivedDateTime,
              '${invoice.value} sats'),
        );
      }
    }

    return allOffChainTxHistory;
  }
}
