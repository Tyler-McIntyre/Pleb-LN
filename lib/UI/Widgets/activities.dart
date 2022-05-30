import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import '../../api/lnd.dart';
import '../../constants/channel_list_tile_icon.dart';
import '../../constants/channel_sort_type.dart';
import '../../constants/channel_status.dart';
import '../../constants/channel_type.dart';
import '../../constants/transfer_type.dart';
import '../../constants/tx_sort_type.dart';
import '../../database/secure_storage.dart';
import '../../models/pending_channels.dart';
import '../../models/pending_open_channel.dart';
import '../../models/transaction_detail.dart';
import '../../models/channel.dart';
import '../../models/channel_detail.dart';
import '../../models/channels.dart';
import '../../models/invoices.dart';
import '../../models/payments.dart';
import '../../util/app_colors.dart';
import '../../util/formatting.dart';
import '../channel_details_screen.dart';
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
  ChannelSortType _channelSortType = ChannelSortType.Id;
  bool _isTxTab = true;

  late Future<List<TransactionDetail>> _transactions;
  late Future<List<ChannelDetail>> _channels;
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
    _channels = _getChannels(_channelSortType);
    super.initState();
  }

  Future<List<TransactionDetail>> _getTransactions(TxSortType sortType) async {
    LND api = LND();
    //TODO: run these in parallel
    Payments payments = await api.getPayments();
    Invoices invoices = await api.getInvoices();
    List<TransactionDetail> txList = [];
    payments.payments.forEach((payment) {
      txList.add(
        TransactionDetail(
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
          TransactionDetail(
              payment.value as String,
              Formatting.timestampToDateTime(
                int.parse(payment.settleDate!),
              ),
              TransferType.received),
        );
      }
    });

    switch (sortType) {
      case TxSortType.DateReceived:
        txList.sort((a, b) {
          return b.dateTime.compareTo(a.dateTime);
        });
        break;
      case TxSortType.Sent:
        txList = txList
            .where((TransactionDetail) =>
                TransactionDetail.transferType == TransferType.sent)
            .toList();
        break;
      case TxSortType.Received:
        txList = txList
            .where((TransactionDetail) =>
                TransactionDetail.transferType == TransferType.received)
            .toList();
        break;
    }

    return txList;
  }

  Future<List<ChannelDetail>> _getChannels(ChannelSortType sortType) async {
    LND api = LND();
    //TODO: run these in parallel
    Channels channels = await api.getChannels();
    PendingChannels pendingChannels = await api.getPendingChannels();
    List<ChannelDetail> channelDetailList = [];

    for (PendingOpenChannel pendingChannel
        in pendingChannels.pendingOpenChannels) {
      String remotePubkeyLabel =
          await SecureStorage.readValue(pendingChannel.channel.remoteNodePub) ??
              pendingChannel.channel.remoteNodePub;

      channelDetailList.add(
        ChannelDetail(
          ChannelStatus.Pending,
          pendingChannel.channel.private ?? true
              ? ChannelType.private
              : ChannelType.public,
          int.parse(pendingChannel.channel.capacity),
          '',
          remotePubkeyLabel,
          ChannelStatus.Pending.name,
          pendingChannel: pendingChannel,
        ),
      );
    }

    for (Channel channel in channels.channels) {
      String channelLabel = await SecureStorage.readValue(channel.chanId) ?? '';
      String remotePubkeyLabel =
          await SecureStorage.readValue(channel.remotePubkey) ??
              channel.remotePubkey;
      print(remotePubkeyLabel);
      channelDetailList.add(
        ChannelDetail(
          channel.active ? ChannelStatus.Active : ChannelStatus.Inactive,
          channel.private ? ChannelType.private : ChannelType.public,
          int.parse(channel.capacity),
          channel.chanId,
          channelLabel.isNotEmpty ? channelLabel : channel.chanId,
          remotePubkeyLabel,
          channel: channel,
        ),
      );
    }

    switch (sortType) {
      case ChannelSortType.Inactive:
        channelDetailList = channelDetailList
            .where((channel) => channel.channelStatus == ChannelStatus.Inactive)
            .toList();
        break;
      case ChannelSortType.Active:
        channelDetailList = channelDetailList
            .where((channel) => channel.channelStatus == ChannelStatus.Active)
            .toList();
        break;
      case ChannelSortType.Capacity:
        channelDetailList.sort((a, b) {
          return b.capacity.compareTo(a.capacity);
        });
        break;
      case ChannelSortType.Private:
        channelDetailList = channelDetailList
            .where((channel) =>
                channel.channelType == ChannelType.private &&
                channel.channelStatus != ChannelStatus.Pending)
            .toList();
        break;
      case ChannelSortType.Public:
        channelDetailList = channelDetailList
            .where((channel) => channel.channelType == ChannelType.public)
            .toList();
        break;
      case ChannelSortType.Id:
        channelDetailList.sort((a, b) {
          return b.channelLabel.compareTo(a.channelLabel);
        });
        break;
      case ChannelSortType.Pending:
        channelDetailList = channelDetailList
            .where((channel) => channel.channelStatus == ChannelStatus.Pending)
            .toList();
        break;
    }
    return channelDetailList;
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
                    onTap: (tabIndex) {
                      setState(() {
                        tabIndex == 0 ? _isTxTab = true : _isTxTab = false;
                      });
                    },
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
                                AsyncSnapshot<List<TransactionDetail>> snapshot,
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
                                AsyncSnapshot<List<ChannelDetail>> snapshot,
                              ) {
                                List<Widget> children = [];
                                if (snapshot.hasData) {
                                  children =
                                      _buildChannelListTiles(snapshot.data!);
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

  _buildTxListTiles(List<TransactionDetail> txList) {
    List<Card> txListTiles = [];

    Icon sentIcon = Icon(Icons.send);
    Icon receivedIcon = Icon(Icons.receipt);

    for (TransactionDetail transactionDetail in txList) {
      bool isSentTx =
          transactionDetail.transferType == TransferType.sent ? true : false;

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
                    text: transactionDetail.transferType.name,
                    style: const TextStyle(color: AppColors.grey, fontSize: 17),
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                  TextSpan(
                    text: Formatting.dateTimeToShortDate(
                        transactionDetail.dateTime),
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
                amount: int.parse(transactionDetail.amount).toDouble(), //amount
              ).output.withoutFractionDigits} sats',
              style: TextStyle(
                fontSize: 19,
                color: (transactionDetail.transferType == TransferType.sent
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

  _buildChannelListTiles(List<ChannelDetail> channelDetails) {
    List<Card> channelListTiles = [];

    for (ChannelDetail channel in channelDetails) {
      Icon? channelIcon = getChannelStatusIcon(channel);

      channelListTiles.add(
        Card(
          color: AppColors.blueGrey,
          child: ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChannelDetailsScreen(
                      channel: channel,
                    ),
                  ));
            },
            style: ListTileStyle.list,
            leading: channelIcon,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${channel.channelStatus == ChannelStatus.Pending ? ChannelStatus.Pending.name : channel.pubKeyLabel}',
                  style: const TextStyle(color: AppColors.grey, fontSize: 17),
                ),
                Text(
                  '${channel.channelLabel}',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
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
                      text: channel.capacity.toString(),
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
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OpenChannelScreen(),
              ));
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: _isTxTab ? _transactionFilterButton() : _channelFilterButton(),
      )
    ];
  }

  Widget _transactionFilterButton() {
    return PopupMenuButton<String>(
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
    );
  }

  Widget _channelFilterButton() {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: AppColors.orange),
      ),
      color: AppColors.blackSecondary,
      icon: const Icon(Icons.filter_alt),
      onSelected: (String result) {
        switch (result) {
          case 'Pending':
            setState(() {
              _channelSortType = ChannelSortType.Pending;
              _channels = _getChannels(_channelSortType);
            });
            break;
          case 'Inactive':
            setState(() {
              _channelSortType = ChannelSortType.Inactive;
              _channels = _getChannels(_channelSortType);
            });
            break;
          case 'Active':
            setState(() {
              _channelSortType = ChannelSortType.Active;
              _channels = _getChannels(_channelSortType);
            });
            break;
          case 'Capacity':
            setState(() {
              _channelSortType = ChannelSortType.Capacity;
              _channels = _getChannels(_channelSortType);
            });
            break;
          case 'Private':
            setState(() {
              _channelSortType = ChannelSortType.Private;
              _channels = _getChannels(_channelSortType);
            });
            break;
          case 'Public':
            setState(() {
              _channelSortType = ChannelSortType.Public;
              _channels = _getChannels(_channelSortType);
            });
            break;
          case 'Id':
            setState(() {
              _channelSortType = ChannelSortType.Id;
              _channels = _getChannels(_channelSortType);
            });
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'Pending',
          child: ListTile(
            leading: Radio<ChannelSortType>(
              fillColor: MaterialStateProperty.all(AppColors.white),
              value: ChannelSortType.Pending,
              groupValue: _channelSortType,
              onChanged: null,
            ),
            tileColor: AppColors.blackSecondary,
            textColor: AppColors.white,
            title: Text(
              'Pending',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Inactive',
          child: ListTile(
            leading: Radio<ChannelSortType>(
              fillColor: MaterialStateProperty.all(AppColors.white),
              value: ChannelSortType.Inactive,
              groupValue: _channelSortType,
              onChanged: null,
            ),
            tileColor: AppColors.blackSecondary,
            textColor: AppColors.white,
            title: Text(
              'Inactive',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Active',
          child: ListTile(
            leading: Radio<ChannelSortType>(
              fillColor: MaterialStateProperty.all(AppColors.white),
              value: ChannelSortType.Active,
              groupValue: _channelSortType,
              onChanged: null,
            ),
            tileColor: AppColors.blackSecondary,
            textColor: AppColors.white,
            title: Text(
              'Active',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Capacity',
          child: ListTile(
            leading: Radio<ChannelSortType>(
              fillColor: MaterialStateProperty.all(AppColors.white),
              value: ChannelSortType.Capacity,
              groupValue: _channelSortType,
              onChanged: null,
            ),
            tileColor: AppColors.blackSecondary,
            textColor: AppColors.white,
            title: Text(
              'Capacity',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Private',
          child: ListTile(
            leading: Radio<ChannelSortType>(
              fillColor: MaterialStateProperty.all(AppColors.white),
              value: ChannelSortType.Private,
              groupValue: _channelSortType,
              onChanged: null,
            ),
            tileColor: AppColors.blackSecondary,
            textColor: AppColors.white,
            title: Text(
              'Private',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Public',
          child: ListTile(
            leading: Radio<ChannelSortType>(
              fillColor: MaterialStateProperty.all(AppColors.white),
              value: ChannelSortType.Public,
              groupValue: _channelSortType,
              onChanged: null,
            ),
            tileColor: AppColors.blackSecondary,
            textColor: AppColors.white,
            title: Text(
              'Public',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Id',
          child: ListTile(
            leading: Radio<ChannelSortType>(
              fillColor: MaterialStateProperty.all(AppColors.white),
              value: ChannelSortType.Id,
              groupValue: _channelSortType,
              onChanged: null,
            ),
            tileColor: AppColors.blackSecondary,
            textColor: AppColors.white,
            title: Text(
              'Id',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
