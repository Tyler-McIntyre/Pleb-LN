import 'package:json_annotation/json_annotation.dart';
part 'pending_channel.g.dart';

@JsonSerializable()
class PendingChannel {
  @JsonKey(name: 'remote_node_pub')
  String remoteNodePub;
  @JsonKey(name: 'channel_point')
  String channelPoint;
  @JsonKey(name: 'capacity')
  String capacity;
  @JsonKey(name: 'local_balance')
  String localBalance;
  @JsonKey(name: 'remote_balance')
  String remoteBalance;
  @JsonKey(name: 'local_chan_reserve_sat')
  String localChanReserveSat;
  @JsonKey(name: 'remote_chan_reserve_sat')
  String remoteChanReserveSat;
  @JsonKey(name: 'private')
  bool? private;
  // @JsonKey(name: 'initiator')
  // Initiator initiator;
  // @JsonKey(name: 'commitment_type')
  // CommitmentType commitment_type;
  // @JsonKey(name: 'num_forwarding_packages')
  // String numForwardingPackages;
  // @JsonKey(name: 'chan_status_flags')
  // String chanStatusFlags;

  PendingChannel(
      this.remoteNodePub,
      this.channelPoint,
      this.capacity,
      this.localBalance,
      this.remoteBalance,
      this.localChanReserveSat,
      this.remoteChanReserveSat,
      this.private
      // this.numForwardingPackages,
      // this.chanStatusFlags,
      );

  factory PendingChannel.fromJson(Map<String, dynamic> json) =>
      _$PendingChannelFromJson(json);

  Map<String, dynamic> toJson() => _$PendingChannelToJson(this);
}
