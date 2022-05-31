import 'package:json_annotation/json_annotation.dart';

import 'channel_point.dart';

part 'update_channel_policy.g.dart';

@JsonSerializable()
class UpdateChannelPolicy {
  @JsonKey(name: 'global')
  bool global;

  @JsonKey(name: 'chan_point')
  ChannelPoint chanPoint;

  @JsonKey(name: 'base_fee_msat')
  String baseFeeMsat;

  @JsonKey(name: 'fee_rate')
  double feeRate;

  // @JsonKey(name: 'fee_rate_ppm')
  // int? feeRatePpm;

  @JsonKey(name: 'time_lock_delta')
  int timeLockDelta;

  // @JsonKey(name: 'max_htlc_msat')
  // String? maxHtlcMsat;

  // @JsonKey(name: 'min_htlc_msat')
  // String minHtlcMsat;

  // @JsonKey(name: 'min_htlc_msat_specified')
  // bool minHtlcMsatSpecified;

  UpdateChannelPolicy(
    this.global,
    this.chanPoint,
    this.baseFeeMsat,
    this.feeRate, {
    this.timeLockDelta = 18,
  }
      // this.feeRatePpm,
      // this.timeLockDelta,
      // this.maxHtlcMsat,
      // this.minHtlcMsat,
      // this.minHtlcMsatSpecified
      );

  factory UpdateChannelPolicy.fromJson(Map<String, dynamic> json) =>
      _$UpdateChannelPolicyFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateChannelPolicyToJson(this);
}
