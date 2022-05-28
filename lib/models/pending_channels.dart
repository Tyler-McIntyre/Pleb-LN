import 'package:json_annotation/json_annotation.dart';
import 'pending_open_channel.dart';

part 'pending_channels.g.dart';

@JsonSerializable()
class PendingChannels {
  @JsonKey(name: 'total_limbo_balance')
  String totalLimboBalance;
  @JsonKey(name: 'pending_open_channels')
  List<PendingOpenChannel> pendingOpenChannels;
  // @JsonKey(name: 'pending_force_closing_channels')
  // String pendingForceClosingChannels;
  // @JsonKey(name: 'waiting_close_channels')
  // String waitingCloseChannels;

  PendingChannels(
    this.totalLimboBalance,
    this.pendingOpenChannels,
  );

  factory PendingChannels.fromJson(Map<String, dynamic> json) =>
      _$PendingChannelsFromJson(json);

  Map<String, dynamic> toJson() => _$PendingChannelsToJson(this);
}
