import 'package:json_annotation/json_annotation.dart';
import 'channel_fee_report.dart';

part 'fee_report.g.dart';

@JsonSerializable()
class FeeReport {
  @JsonKey(name: 'channel_fees')
  List<ChannelFeeReport> channelFees;
  @JsonKey(name: 'day_fee_sum')
  String dayFeeSum;
  @JsonKey(name: 'week_fee_sum')
  String weekFeeSum;
  @JsonKey(name: 'month_fee_sum')
  String monthFeeSum;

  FeeReport(
    this.channelFees,
    this.dayFeeSum,
    this.weekFeeSum,
    this.monthFeeSum,
  );

  factory FeeReport.fromJson(Map<String, dynamic> json) =>
      _$FeeReportFromJson(json);

  Map<String, dynamic> toJson() => _$FeeReportToJson(this);
}
