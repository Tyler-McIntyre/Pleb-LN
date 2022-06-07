import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../UI/widgets/balance.dart';
import '../generated/lightning.pbgrpc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import '../constants/channel_list_tile_icon.dart';
import '../constants/channel_sort_type.dart';
import '../constants/channel_status.dart';
import '../constants/channel_type.dart';
import '../database/secure_storage.dart';
import '../models/channel_detail.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import '../util/refresh_timer.dart';
import 'channel_details_screen.dart';
import 'widgets/future_builder_widgets.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({Key? key}) : super(key: key);

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  ChannelSortType _channelSortType = ChannelSortType.Id;
  Duration refreshInterval = Duration(seconds: 15);
  late Future<List<ChannelDetail>> _channels;
  late List<Widget> _offChainBalanceWidgets;
  static int offChainBalanceWidgetIndex = 0;
  late Future<ChannelBalanceResponse> _offChainBalance;
  TextEditingController nicknameController = TextEditingController();
  final List<ChannelSortType> filters = [
    ChannelSortType.Active,
    ChannelSortType.Capacity,
    ChannelSortType.Id,
    ChannelSortType.Inactive,
    ChannelSortType.Pending,
    ChannelSortType.Private,
    ChannelSortType.Public,
  ];
  ChannelSortType? selectedValue;
  int count = 0;

  @override
  void initState() {
    _offChainBalance = _getOffChainBalance();
    selectedValue = _channelSortType;
    _channels = _getChannels(_channelSortType);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String nickname = await _getNickname();
      RefreshTimer.refreshTimer = Timer.periodic(
          refreshInterval, (timer) => _sweepForChannelUpdates(timer));
      if (!mounted) return;
      setState(() {
        nicknameController.text = nickname;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    RefreshTimer.refreshTimer!.cancel();
    super.dispose();
  }

  _sweepForChannelUpdates(Timer t) async {
    List<ChannelDetail> result = await _getChannels(_channelSortType);
    List<ChannelDetail> currentChanDetails = await _channels;

    Map<int, int> currentChanCounts = {
      currentChanDetails.where((item) => item.channel != null).length:
          currentChanDetails.where((item) => item.pendingChannel != null).length
    };

    Map<int, int> newChanCounts = {
      result.where((item) => item.channel != null).length:
          result.where((item) => item.pendingChannel != null).length
    };

    bool areEqual = mapEquals(currentChanCounts, newChanCounts);

    if (!areEqual) {
      if (!mounted) return;
      setState(() {
        _channels = Future.value(result);
        _offChainBalance = _getOffChainBalance();
      });
    }
  }

  Future<String> _getNickname() async {
    final String nickname = await SecureStorage.readValue('nickname') ?? '';
    return nickname;
  }

  Future<List<ChannelDetail>> _getChannels(ChannelSortType sortType) async {
    LND rpc = LND();
    ListChannelsResponse channels = await rpc.getChannels();
    PendingChannelsResponse pendingChannels = await rpc.getPendingChannels();
    List<ChannelDetail> channelDetailList = [];

    for (PendingChannelsResponse_PendingOpenChannel pendingChannel
        in pendingChannels.pendingOpenChannels) {
      String? remotePubkeyLabel =
          await SecureStorage.readValue(pendingChannel.channel.remoteNodePub);

      remotePubkeyLabel != null && remotePubkeyLabel.isNotEmpty
          ? remotePubkeyLabel = remotePubkeyLabel
          : remotePubkeyLabel = pendingChannel.channel.remoteNodePub;

      channelDetailList.add(
        ChannelDetail(
          ChannelStatus.Pending,
          pendingChannel.channel.private
              ? ChannelType.private
              : ChannelType.public,
          pendingChannel.channel.capacity.toInt(),
          '',
          remotePubkeyLabel,
          ChannelStatus.Pending.name,
          pendingChannel: pendingChannel,
        ),
      );
    }

    for (Channel channel in channels.channels) {
      String channelLabel =
          await SecureStorage.readValue(channel.chanId.toString()) ?? '';
      String? remotePubkeyLabel =
          await SecureStorage.readValue(channel.remotePubkey);

      remotePubkeyLabel != null && remotePubkeyLabel.isNotEmpty
          ? remotePubkeyLabel = remotePubkeyLabel
          : remotePubkeyLabel = channel.remotePubkey;

      channelDetailList.add(
        ChannelDetail(
          channel.active ? ChannelStatus.Active : ChannelStatus.Inactive,
          channel.private ? ChannelType.private : ChannelType.public,
          channel.capacity.toInt(),
          channel.chanId.toString(),
          channelLabel.isNotEmpty ? channelLabel : channel.chanId.toString(),
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
            .where((channel) =>
                channel.channelType == ChannelType.public &&
                channel.channelStatus != ChannelStatus.Pending)
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
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(nicknameController.text,
                  style: Theme.of(context).textTheme.bodyLarge),
              _offChainBalanceFutureBuilder(),
            ],
          ),
        ),
        _buttonBar(),
        _channelFutureBuilder(),
      ],
    );
  }

  FutureBuilder _channelFutureBuilder() {
    return FutureBuilder<List<ChannelDetail>>(
      future: _channels,
      builder: (
        context,
        AsyncSnapshot<List<ChannelDetail>> snapshot,
      ) {
        Widget child;
        if (snapshot.hasData) {
          child = MediaQuery.removePadding(
            context: context,
            child: Scrollbar(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Column(children: _buildChannelListTiles(snapshot.data!))
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          child = Column(
            children: [
              Expanded(
                child: FutureBuilderWidgets.error(
                  context,
                  snapshot.error.toString(),
                ),
              )
            ],
          );
        } else {
          child = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FutureBuilderWidgets.circularProgressIndicator(),
              ),
            ],
          );
        }
        return Expanded(
          flex: 2,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topRight,
                colors: [
                  AppColors.blue,
                  AppColors.black,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: child,
          ),
        );
      },
    );
  }

  _buildChannelListTiles(List<ChannelDetail> channelDetails) {
    List<ListTile> channelListTiles = [];

    for (ChannelDetail channel in channelDetails) {
      bool pendingChannel =
          channel.channelStatus == ChannelStatus.Pending ? true : false;
      bool private =
          channel.channel != null && channel.channel!.private ? true : false;
      bool active =
          channel.channel != null && channel.channel!.active ? true : false;

      Icon? channelIcon = getChannelStatusIcon(active, private, pendingChannel);

      channelListTiles.add(
        ListTile(
          onTap: () async {
            if (channel.channelStatus != ChannelStatus.Pending) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChannelDetailsScreen(
                      channel: channel.channel!,
                    ),
                  ));
            } else {
              await pendingChannelDialog(context);
            }
          },
          style: ListTileStyle.list,
          leading: channelIcon,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${channel.channelStatus == ChannelStatus.Pending ? ChannelStatus.Pending.name : channel.pubKeyLabel}',
                style: Theme.of(context).textTheme.labelSmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                '${channel.channelLabel}',
                style: Theme.of(context).textTheme.displaySmall,
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
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text.rich(
                TextSpan(
                    text: MoneyFormatter(
                      amount: int.parse(channel.capacity.toString()).toDouble(),
                    ).output.withoutFractionDigits,
                    children: [
                      TextSpan(
                        text: 'sats',
                        style: Theme.of(context).textTheme.labelSmall,
                      )
                    ],
                    style: Theme.of(context).textTheme.labelMedium),
              ),
            ],
          ),
        ),
      );
    }

    return channelListTiles;
  }

  _buttonBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Channels:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              style: TextStyle(color: AppColors.white),
              items: filters
                  .map((item) => DropdownMenuItem<ChannelSortType>(
                        value: item,
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ))
                  .toList(),
              value: selectedValue,
              onChanged: (value) {
                switch (value) {
                  case (ChannelSortType.Active):
                    _channelSortType = ChannelSortType.Active;
                    break;
                  case (ChannelSortType.Capacity):
                    _channelSortType = ChannelSortType.Capacity;
                    break;
                  case (ChannelSortType.Id):
                    _channelSortType = ChannelSortType.Id;
                    break;
                  case (ChannelSortType.Inactive):
                    _channelSortType = ChannelSortType.Inactive;
                    break;
                  case (ChannelSortType.Pending):
                    _channelSortType = ChannelSortType.Pending;
                    break;
                  case (ChannelSortType.Private):
                    _channelSortType = ChannelSortType.Private;
                    break;
                  case (ChannelSortType.Public):
                    _channelSortType = ChannelSortType.Public;
                    break;
                }
                if (!mounted) return;
                setState(() {
                  selectedValue = value as ChannelSortType;
                  _channels = _getChannels(_channelSortType);
                });
              },
              buttonHeight: 40,
              buttonWidth: 140,
              itemHeight: 40,
              dropdownMaxHeight: 200,
              dropdownWidth: 140,
              dropdownPadding: EdgeInsets.only(bottom: 8),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  FutureBuilder _offChainBalanceFutureBuilder() {
    return FutureBuilder<ChannelBalanceResponse>(
      future: _offChainBalance,
      builder: (BuildContext context,
          AsyncSnapshot<ChannelBalanceResponse> snapshot) {
        Widget child;
        if (snapshot.hasData) {
          child = TextButton(
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _changeOffChainBalanceWidget();
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _offChainBalanceWidgets[offChainBalanceWidgetIndex],
              ],
            ),
          );
        } else if (snapshot.hasError) {
          child = FutureBuilderWidgets.error(
            context,
            snapshot.error.toString(),
          );
        } else {
          child = Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            ),
          );
        }
        return child;
      },
    );
  }

  void _changeOffChainBalanceWidget() {
    offChainBalanceWidgetIndex >= _offChainBalanceWidgets.length - 1
        ? offChainBalanceWidgetIndex = 0
        : offChainBalanceWidgetIndex += 1;
  }

  Future<ChannelBalanceResponse> _getOffChainBalance() async {
    LND rpc = LND();
    ChannelBalanceResponse result = await rpc.getChannelBalance();
    String localChannelBalance = result.localBalance.sat.toString();

    _offChainBalanceWidgets =
        await Balance.buildWidgets(localChannelBalance, context);
    return result;
  }

  Future<void> pendingChannelDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Icon(
          Icons.info_outline,
          color: AppColors.blue,
          size: 35,
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'The status of this channel is pending. Once the channel has been successfully opened you can view it\'s details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blue, fontSize: 20),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Got it!',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
