import 'package:json_annotation/json_annotation.dart';
part 'channel.g.dart';

@JsonSerializable(explicitToJson: true)
class Channel {
  @JsonKey(name: 'active')
  bool active;

  @JsonKey(name: 'remote_pubkey')
  String remotePubkey;

  @JsonKey(name: 'channel_point')
  String channelPoint;

  @JsonKey(name: 'chan_id')
  String chanId;

  @JsonKey(name: 'capacity')
  String capacity;

  @JsonKey(name: 'local_balance')
  String localBalance;

  @JsonKey(name: 'remote_balance')
  String remoteBalance;

  @JsonKey(name: 'commit_fee')
  String commitFee;

  @JsonKey(name: 'commit_weight')
  String commitWeight;

  @JsonKey(name: 'fee_per_kw')
  String feePerKw;

  @JsonKey(name: 'unsettled_balance')
  String unsettledBalance;

  @JsonKey(name: 'total_satoshis_sent')
  String totalSatoshisSent;

  @JsonKey(name: 'total_satoshis_received')
  String totalSatoshisReceived;

  @JsonKey(name: 'num_updates')
  String numUpdates;

  // @JsonKey(name: 'pending_htlcs')
  // List<HTLC> pendingHtlcs;

  @JsonKey(name: 'private')
  bool private;

  @JsonKey(name: 'initiator')
  bool initiator;

  @JsonKey(name: 'chan_status_flags')
  String chanStatusFlags;

  // @JsonKey(name: 'commitment_type')
  // CommitmentType commitmentType;

  @JsonKey(name: 'lifetime')
  String lifetime;

  @JsonKey(name: 'uptime')
  String uptime;

  @JsonKey(name: 'close_address')
  String closeAddress;

  @JsonKey(name: 'push_amount_sat')
  String pushAmountSat;

  @JsonKey(name: 'thaw_height')
  int thawHeight;

  // @JsonKey(name: 'local_constraints')
  // ChannelConstraints localConstraints;

  // @JsonKey(name: 'remote_constraints')
  // ChannelConstraints remote_constraints;

  Channel(
    this.active,
    this.remotePubkey,
    this.channelPoint,
    this.chanId,
    this.capacity,
    this.localBalance,
    this.remoteBalance,
    this.commitFee,
    this.commitWeight,
    this.feePerKw,
    this.unsettledBalance,
    this.totalSatoshisSent,
    this.totalSatoshisReceived,
    this.numUpdates,
    this.private,
    this.initiator,
    this.chanStatusFlags,
    this.lifetime,
    this.uptime,
    this.closeAddress,
    this.pushAmountSat,
    this.thawHeight,
  );

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}
