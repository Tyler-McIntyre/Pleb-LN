import '../constants/channel_status.dart';
import '../constants/channel_type.dart';
import 'channel.dart';
import 'pending_open_channel.dart';

class ChannelDetail {
  ChannelStatus channelStatus;
  ChannelType channelType;
  int capacity;
  String chanId;
  String label;
  PendingOpenChannel? pendingChannel;
  Channel? channel;

  ChannelDetail(
    this.channelStatus,
    this.channelType,
    this.capacity,
    this.chanId,
    this.label, {
    this.pendingChannel,
    this.channel,
  });
}
