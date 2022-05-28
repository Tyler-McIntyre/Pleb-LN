import '../constants/channel_status.dart';
import '../constants/channel_type.dart';

class ChannelDetail {
  ChannelStatus channelStatus;
  ChannelType channelType;
  int capacity;
  String chanId;
  String alias;

  ChannelDetail(
    this.channelStatus,
    this.channelType,
    this.capacity,
    this.chanId,
    this.alias,
  );
}
