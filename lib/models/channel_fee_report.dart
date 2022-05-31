import 'package:json_annotation/json_annotation.dart';

part 'channel_fee_report.g.dart';

@JsonSerializable()
class ChannelFeeReport {
  @JsonKey(name: 'chan_id')
  String chanId;
  @JsonKey(name: 'channel_point')
  String channelPoint;
  @JsonKey(name: 'base_fee_msat')
  String baseFeeMsat;
  @JsonKey(name: 'fee_per_mil')
  String feePerMil;
  @JsonKey(name: 'fee_rate')
  double feeRate;

  ChannelFeeReport(
    this.chanId,
    this.channelPoint,
    this.baseFeeMsat,
    this.feePerMil,
    this.feeRate,
  );

  factory ChannelFeeReport.fromJson(Map<String, dynamic> json) =>
      _$ChannelFeeReportFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelFeeReportToJson(this);
}
