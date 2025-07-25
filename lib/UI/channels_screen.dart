import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pleb_ln/UI/widgets/future_builder_widgets.dart';
import '../provider/balance_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../UI/widgets/balance.dart';
import '../generated/lightning.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import '../constants/channel_list_tile_icon.dart';
import '../constants/channel_sort_type.dart';
import '../constants/channel_status.dart';
import '../constants/channel_type.dart';
import '../models/channel_detail.dart';
import '../provider/channel_provider.dart';
import '../provider/database_provider.dart';
import '../provider/index_provider.dart';
import '../provider/sorting_provider.dart';
import '../util/app_colors.dart';
import 'channel_details_screen.dart';

class ChannelsScreen extends ConsumerWidget {
  ChannelsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //poll for updates
    ref.watch(BalanceProvider.channelBalanceStream);
    ref.watch(ChannelProvider.channelStream);

    //fetch the alias
    AsyncValue<String> alias = ref.watch(DatabaseProvider.alias);

    //fetch the local channel balance
    ChannelBalanceResponse channelBalanceResponse =
        ref.watch(BalanceProvider.channelBalance);
    int balanceIndex = ref.watch(IndexProvider.balanceTypeIndex);

    //build the balance widgets
    List<Widget> _balanceWidgets = Balance.buildWidgets(
        channelBalanceResponse.localBalance.sat.toString(), context, ref);

    //set the sort type
    ChannelSortType _channelSortType =
        ref.watch(SortingProvider.channelSortTypeProvider);

    //fetch the channel data
    ListChannelsResponse openChannels = ref.watch(ChannelProvider.openChannels);

    PendingChannelsResponse pendingChannels =
        ref.watch(ChannelProvider.pendingChannels);
    List<ChannelDetail> _channelDetails = _getChannelDetails(
        _channelSortType, openChannels, pendingChannels, ref);

    void _changeOffChainBalanceWidget() {
      balanceIndex >= _balanceWidgets.length - 1
          ? ref.read(IndexProvider.balanceTypeIndex.notifier).state = 0
          : ref.read(IndexProvider.balanceTypeIndex.notifier).state += 1;
    }

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              alias.when(
                data: (alias) {
                  return Text(alias,
                      style: Theme.of(context).textTheme.bodyLarge);
                },
                error: (err, stack) =>
                    FutureBuilderWidgets.error(context, err.toString()),
                loading: () =>
                    CircularProgressIndicator(color: AppColors.white),
              ),
              //Balance widget
              TextButton(
                onPressed: () {
                  _changeOffChainBalanceWidget();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _balanceWidgets[balanceIndex],
                  ],
                ),
              )
              //Balance widget
            ],
          ),
        ),
        //ButtonBar
        Padding(
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
                  items: ChannelFilters.filters
                      .map((item) => DropdownMenuItem<ChannelSortType>(
                            value: item,
                            child: Text(
                              item.name == ChannelSortType.LocalBalance.name
                                  ? 'Local Balance'
                                  : item.name,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ))
                      .toList(),
                  value: _channelSortType,
                  onChanged: (value) {
                    switch (value) {
                      case (ChannelSortType.Active):
                        _channelSortType = ChannelSortType.Active;
                        break;
                      case (ChannelSortType.LocalBalance):
                        _channelSortType = ChannelSortType.LocalBalance;
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
                    ref
                        .read(SortingProvider.channelSortTypeProvider.notifier)
                        .state = value as ChannelSortType;
                    _channelDetails = _getChannelDetails(
                        _channelSortType, openChannels, pendingChannels, ref);
                  },
                  // buttonHeight: 40,
                  // buttonWidth: 140,
                  // itemHeight: 40,
                  // dropdownMaxHeight: 250,
                  // dropdownWidth: 140,
                  // dropdownPadding: EdgeInsets.only(bottom: 8),
                  // dropdownDecoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(14),
                  //   color: AppColors.black,
                  // ),
                ),
              ),
            ],
          ),
        ),
        //ButtonBar,
        //Channel list
        Expanded(
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
            child: MediaQuery.removePadding(
              context: context,
              child: Scrollbar(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Column(
                        children:
                            _buildChannelListTiles(context, _channelDetails))
                  ],
                ),
              ),
            ),
          ),
        )
        //Channel list
      ],
    );
  }

  List<Widget> _buildChannelListTiles(
      BuildContext context, List<ChannelDetail> channelDetails) {
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
                    builder: (context) => ChannelDetailProvider(
                      channel.channel!,
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
                'Local Balance',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text.rich(
                TextSpan(
                    text: MoneyFormatter(
                      amount: channel.localBalance.toInt().toDouble(),
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

  List<ChannelDetail> _getChannelDetails(
    ChannelSortType sortType,
    ListChannelsResponse openChannels,
    PendingChannelsResponse pendingChannels,
    WidgetRef ref,
  ) {
    List<ChannelDetail> channelDetailList = [];

    for (PendingChannelsResponse_PendingOpenChannel pendingChannel
        in pendingChannels.pendingOpenChannels) {
      String? remotePubKey = pendingChannel.channel.remoteNodePub;
      AsyncValue<String> remotePubkeyLabel =
          ref.watch(DatabaseProvider.remotePubKeyLabel(remotePubKey));

      channelDetailList.add(
        ChannelDetail(
          ChannelStatus.Pending,
          pendingChannel.channel.private
              ? ChannelType.private
              : ChannelType.public,
          pendingChannel.channel.localBalance.toInt(),
          '',
          remotePubkeyLabel.when(
              data: (remotePubkeyLabel) {
                return remotePubkeyLabel.isNotEmpty
                    ? remotePubkeyLabel = remotePubkeyLabel
                    : remotePubkeyLabel = remotePubKey;
              },
              error: (err, stack) => '',
              loading: () => remotePubKey),
          ChannelStatus.Pending.name,
          pendingChannel: pendingChannel,
        ),
      );
    }

    for (Channel channel in openChannels.channels) {
      String chanId = channel.chanId.toString();
      AsyncValue<String> channelLabel =
          ref.watch(DatabaseProvider.channelLabel(chanId));

      String remotePubKey = channel.remotePubkey;
      AsyncValue<String> remotePubkeyLabel =
          ref.watch(DatabaseProvider.remotePubKeyLabel(remotePubKey));

      channelDetailList.add(
        ChannelDetail(
          channel.active ? ChannelStatus.Active : ChannelStatus.Inactive,
          channel.private ? ChannelType.private : ChannelType.public,
          channel.localBalance.toInt(),
          chanId,
          channelLabel.when(
              data: (channelLabel) {
                return channelLabel.isNotEmpty ? channelLabel : chanId;
              },
              error: (err, stack) => '',
              loading: () => chanId),
          remotePubkeyLabel.when(
              data: (remotePubkeyLabel) {
                return remotePubkeyLabel.isNotEmpty
                    ? remotePubkeyLabel = remotePubkeyLabel
                    : remotePubkeyLabel = remotePubKey;
              },
              error: (err, stack) => '',
              loading: () => remotePubKey),
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
      case ChannelSortType.LocalBalance:
        channelDetailList.sort((a, b) {
          return b.localBalance.compareTo(a.localBalance);
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
        channelDetailList.reversed.toList().sort((a, b) {
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
}
