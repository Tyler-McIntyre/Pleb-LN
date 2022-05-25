import 'package:firebolt/models/payment_response.dart';
import 'package:firebolt/util/formatting.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:tuple/tuple.dart';
import '../../api/lnd.dart';
import '../../models/invoice.dart';
import '../../models/invoices.dart';
import '../../models/payments.dart';
import '../../util/app_colors.dart';

enum activitySortOptions { DateReceived, SentOnly, ReceivedOnly }

class Activities extends StatefulWidget {
  const Activities({Key? key, required this.nodeIsConfigured})
      : super(key: key);
  final bool nodeIsConfigured;

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  activitySortOptions? _activitySortOption = activitySortOptions.DateReceived;
  late List<Tuple5<Icon, String, String, DateTime, String>> offChainTxHistory;
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

    //build the on chain UTXO luist

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
                  title: Text(
                    'Activity',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
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
                          return widget.nodeIsConfigured
                              ? FutureBuilder(
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
                                        _activityCardList = _buildActivityCards(
                                            offChainTxHistory);
                                      }
                                      children = _activityCardList;
                                    } else if (snapshot.hasError) {
                                      children = <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.25,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: const Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red,
                                                  size: 40,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16),
                                                child: Text(
                                                  'Error: ${snapshot.error}',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .errorColor),
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
                                              padding: const EdgeInsets.only(
                                                  top: 50.0),
                                              child: SizedBox(
                                                width: 60,
                                                height: 60,
                                                child:
                                                    CircularProgressIndicator(),
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
                                )
                              : SizedBox.shrink();
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
                    style: const TextStyle(color: AppColors.grey, fontSize: 17),
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                  TextSpan(
                    text: Formatting.dateTimeToShortDate(tx.item4), //date
                    style: const TextStyle(fontSize: 18),
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                ],
              ),
            ),
            trailing: Text(
              '${MoneyFormatter(
                amount: int.parse(tx.item5).toDouble(), //amount
              ).output.withoutFractionDigits} sats',
              style: TextStyle(
                fontSize: 19,
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
      PopupMenuButton<String>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(color: AppColors.orange),
        ),
        color: AppColors.blackSecondary,
        icon: const Icon(Icons.filter_alt),
        onSelected: (String result) {
          switch (result) {
            case 'Date':
              setState(() {
                _activitySortOption = activitySortOptions.DateReceived;
                _activityCardList = _buildActivityCards(offChainTxHistory);
              });
              break;
            case 'Sent':
              setState(() {
                _activitySortOption = activitySortOptions.SentOnly;
                _activityCardList = _buildActivityCards(offChainTxHistory
                    .where((element) => element.item2.toLowerCase() == 'sent')
                    .toList());
              });
              break;
            case 'Received':
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
            value: 'Date',
            child: ListTile(
              leading: Radio<activitySortOptions>(
                fillColor: MaterialStateProperty.all(AppColors.white),
                value: activitySortOptions.DateReceived,
                groupValue: _activitySortOption,
                onChanged: null,
              ),
              tileColor: AppColors.blackSecondary,
              textColor: AppColors.white,
              title: Text('Date'),
            ),
          ),
          PopupMenuItem<String>(
            value: 'Sent',
            child: ListTile(
              leading: Radio<activitySortOptions>(
                fillColor: MaterialStateProperty.all(AppColors.white),
                value: activitySortOptions.SentOnly,
                groupValue: _activitySortOption,
                onChanged: null,
              ),
              tileColor: AppColors.blackSecondary,
              textColor: AppColors.white,
              title: Text('Sent'),
            ),
          ),
          PopupMenuItem<String>(
            value: 'Received',
            child: ListTile(
              leading: Radio<activitySortOptions>(
                fillColor: MaterialStateProperty.all(AppColors.white),
                value: activitySortOptions.ReceivedOnly,
                groupValue: _activitySortOption,
                onChanged: null,
              ),
              tileColor: AppColors.blackSecondary,
              textColor: AppColors.white,
              title: Text('Received'),
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
            payment.valueSat),
      );
    }

    Invoices invoices = await api.getInvoices();
    for (Invoice invoice in invoices.invoices) {
      DateTime receivedDateTime =
          Formatting.timestampToDateTime(int.parse(invoice.settleDate!));

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
              invoice.value.toString()),
        );
      }
    }

    return allOffChainTxHistory;
  }
}
