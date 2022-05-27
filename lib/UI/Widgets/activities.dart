import 'package:firebolt/models/channels.dart';
import 'package:firebolt/util/formatting.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import '../../api/lnd.dart';
import '../../constants/channel_type.dart';
import '../../constants/transfer_type.dart';
import '../../constants/tx_sort_type.dart';
import '../../models/channel.dart';
import '../../models/invoices.dart';
import '../../models/payments.dart';
import '../../util/app_colors.dart';
import '../open_channel_screen.dart';

class Activities extends StatefulWidget {
  const Activities({Key? key, required this.nodeIsConfigured})
      : super(key: key);
  final bool nodeIsConfigured;

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  TxSortType _txSortType = TxSortType.DateReceived;
  late Future<List<Tx>> _transactions;
  late Future<Channels> _channels;
  final Map<String, Icon> _tabs = {
    'Transactions': const Icon(
      Icons.bolt,
      color: AppColors.yellow,
      size: 25,
    ),
    'Channels': const Icon(
      Icons.network_check_outlined,
      color: AppColors.orange,
      size: 25,
    ),
  };

  @override
  void initState() {
    _transactions = _getTransactions(_txSortType);
    _channels = _getChannels();
    super.initState();
  }

  Future<List<Tx>> _getTransactions(TxSortType sortOption) async {
    LND api = LND();
    Payments payments = await api.getPayments();
    Invoices invoices = await api.getInvoices();
    List<Tx> txList = [];
    payments.payments.forEach((payment) {
      txList.add(
        Tx(
            payment.valueSat,
            Formatting.timestampNanoSecondsToDate(
              int.parse(payment.creationTimeNanoSeconds),
            ),
            TransferType.sent),
      );
    });

    invoices.invoices.forEach((payment) {
      if (payment.settled == true &&
          payment.value!.isNotEmpty &&
          payment.settleDate!.isNotEmpty) {
        txList.add(
          Tx(
              payment.value as String,
              Formatting.timestampToDateTime(
                int.parse(payment.settleDate!),
              ),
              TransferType.received),
        );
      }
    });

    switch (sortOption) {
      case TxSortType.DateReceived:
        txList.sort((a, b) {
          return b.dateTime.compareTo(a.dateTime);
        });
        break;
      case TxSortType.Sent:
        txList =
            txList.where((tx) => tx.transferType == TransferType.sent).toList();
        break;
      case TxSortType.Received:
        txList = txList
            .where((tx) => tx.transferType == TransferType.received)
            .toList();
        break;
    }

    return txList;
  }

  Future<Channels> _getChannels() async {
    LND api = LND();
    Channels channels = await api.getChannels();
    return channels;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Container(
        color: AppColors.black,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  primary: false,
                  automaticallyImplyLeading: false,
                  actions: _actionsButtonBar(),
                  backgroundColor: AppColors.black,
                  title: Text(
                    'Balance info',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  pinned: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    tabs: _tabs.entries
                        .map(
                          (tab) => Tab(
                            icon: tab.value,
                            child: Text(
                              tab.key,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _transactionsTabView(_tabs.entries.first),
              _channelsTabView(_tabs.entries.last)
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionsTabView(MapEntry<String, Icon> tab) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            key: PageStorageKey<String>(tab.key),
            slivers: <Widget>[
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 0),
                sliver: SliverFixedExtentList(
                  itemExtent: 300,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return widget.nodeIsConfigured
                          ? FutureBuilder(
                              future: _transactions,
                              builder: (
                                context,
                                AsyncSnapshot<List<Tx>> snapshot,
                              ) {
                                List<Widget> children = [];
                                if (snapshot.hasData) {
                                  children = _buildTxListTiles(snapshot.data!);
                                } else if (snapshot.hasError) {
                                  children = <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.25,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 16),
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
  }

  Widget _channelsTabView(MapEntry<String, Icon> tab) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            key: PageStorageKey<String>(tab.key),
            slivers: <Widget>[
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 0),
                sliver: SliverFixedExtentList(
                  itemExtent: 300,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return widget.nodeIsConfigured
                          ? FutureBuilder(
                              future: _channels,
                              builder: (
                                context,
                                AsyncSnapshot<Channels> snapshot,
                              ) {
                                List<Widget> children = [];
                                if (snapshot.hasData) {
                                  children = _buildChannelListTiles(
                                      snapshot.data!.channels);
                                } else if (snapshot.hasError) {
                                  children = <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.25,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 16),
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
  }

  _buildTxListTiles(List<Tx> txList) {
    List<Card> txListTiles = [];

    Icon sentIcon = Icon(Icons.send);
    Icon receivedIcon = Icon(Icons.receipt);

    for (Tx tx in txList) {
      bool isSentTx = tx.transferType == TransferType.sent ? true : false;

      txListTiles.add(
        Card(
          color: AppColors.blueGrey,
          child: ListTile(
            // onTap: (){}, //TODO: navigate to transaction details page
            style: ListTileStyle.list,
            leading: isSentTx ? sentIcon : receivedIcon,
            title: Text.rich(
              TextSpan(
                text: null,
                children: [
                  TextSpan(
                    text: tx.transferType.name,
                    style: const TextStyle(color: AppColors.grey, fontSize: 17),
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                  TextSpan(
                    text: Formatting.dateTimeToShortDate(tx.dateTime),
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
                amount: int.parse(tx.amount).toDouble(), //amount
              ).output.withoutFractionDigits} sats',
              style: TextStyle(
                fontSize: 19,
                color: (tx.transferType == TransferType.sent
                    ? AppColors.red
                    : AppColors.green),
              ),
            ),
          ),
        ),
      );
    }

    return txListTiles;
  }

  _buildChannelListTiles(List<Channel> channels) {
    List<Card> channelListTiles = [];
    Icon activeIcon;
    Icon inactiveIcon;

    for (Channel channel in channels) {
      bool isActive = channel.active ? true : false;

      if (!channel.private) {
        activeIcon = Icon(
          Icons.public,
          color: AppColors.green,
        );
        inactiveIcon = Icon(
          Icons.public,
          color: AppColors.red,
        );
      } else {
        activeIcon = Icon(
          Icons.private_connectivity,
          color: AppColors.green,
        );
        inactiveIcon = Icon(
          Icons.private_connectivity,
          color: AppColors.red,
        );
      }

      channelListTiles.add(
        Card(
          color: AppColors.blueGrey,
          child: ListTile(
            // onTap: (){}, //TODO: navigate to channel details page
            style: ListTileStyle.list,
            leading: isActive ? activeIcon : inactiveIcon,
            title: Text.rich(
              TextSpan(
                text: null,
                children: [
                  TextSpan(
                    text: channel.private
                        ? ChannelType.private.name
                        : ChannelType.public.name,
                    style: const TextStyle(color: AppColors.grey, fontSize: 17),
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                  TextSpan(
                    text: channel.chanId,
                    style: const TextStyle(fontSize: 18),
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Capacity',
                  style: TextStyle(color: AppColors.grey, fontSize: 16),
                ),
                Text.rich(
                  TextSpan(
                      text: channel.capacity,
                      style: Theme.of(context).textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: 'sats',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return channelListTiles;
  }

  _actionsButtonBar() {
    return [
      IconButton(
        icon: Icon(Icons.connect_without_contact),
        onPressed: () {
          //TODO: redirect to OpenChannel screen
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OpenChannelScreen(),
              ));
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: PopupMenuButton<String>(
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
                  _txSortType = TxSortType.DateReceived;
                  _transactions = _getTransactions(_txSortType);
                });
                break;
              case 'Sent':
                setState(() {
                  _txSortType = TxSortType.Sent;
                  _transactions = _getTransactions(_txSortType);
                });
                break;
              case 'Received':
                setState(() {
                  _txSortType = TxSortType.Received;
                  _transactions = _getTransactions(_txSortType);
                });
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'Date',
              child: ListTile(
                leading: Radio<TxSortType>(
                  fillColor: MaterialStateProperty.all(AppColors.white),
                  value: TxSortType.DateReceived,
                  groupValue: _txSortType,
                  onChanged: null,
                ),
                tileColor: AppColors.blackSecondary,
                textColor: AppColors.white,
                title: Text(
                  'Date',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'Sent',
              child: ListTile(
                leading: Radio<TxSortType>(
                  fillColor: MaterialStateProperty.all(AppColors.white),
                  value: TxSortType.Sent,
                  groupValue: _txSortType,
                  onChanged: null,
                ),
                tileColor: AppColors.blackSecondary,
                textColor: AppColors.white,
                title: Text(
                  'Sent',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'Received',
              child: ListTile(
                leading: Radio<TxSortType>(
                  fillColor: MaterialStateProperty.all(AppColors.white),
                  value: TxSortType.Received,
                  groupValue: _txSortType,
                  onChanged: null,
                ),
                tileColor: AppColors.blackSecondary,
                textColor: AppColors.white,
                title: Text(
                  'Received',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      )
    ];
  }
}

class Tx {
  String amount;
  DateTime dateTime;
  TransferType transferType;
  Tx(this.amount, this.dateTime, this.transferType);
}
