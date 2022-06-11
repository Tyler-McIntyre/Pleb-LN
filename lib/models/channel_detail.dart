import '../constants/channel_status.dart';
import '../constants/channel_type.dart';
import '../generated/lightning.pb.dart';

class ChannelDetail {
  ChannelStatus channelStatus;
  ChannelType channelType;
  int localBalance;
  String chanId;
  String channelLabel;
  String pubKeyLabel;
  PendingChannelsResponse_PendingOpenChannel? pendingChannel;
  Channel? channel;

  ChannelDetail(
    this.channelStatus,
    this.channelType,
    this.localBalance,
    this.chanId,
    this.channelLabel,
    this.pubKeyLabel, {
    this.pendingChannel,
    this.channel,
  });
}
