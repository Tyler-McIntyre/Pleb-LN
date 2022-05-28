import 'package:json_annotation/json_annotation.dart';
import 'pending_channel.dart';

part 'pending_open_channel.g.dart';

@JsonSerializable()
class PendingOpenChannel {
  @JsonKey(name: 'channel')
  PendingChannel channel;

  @JsonKey(name: 'commit_fee')
  String commitFee;

  @JsonKey(name: 'commit_weight')
  String commitWeight;

  @JsonKey(name: 'fee_per_kw')
  String feePerKw;

  PendingOpenChannel(
    this.channel,
    this.commitFee,
    this.commitWeight,
    this.feePerKw,
  );

  factory PendingOpenChannel.fromJson(Map<String, dynamic> json) =>
      _$PendingOpenChannelFromJson(json);

  Map<String, dynamic> toJson() => _$PendingOpenChannelToJson(this);
}
