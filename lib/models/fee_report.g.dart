// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeeReport _$FeeReportFromJson(Map<String, dynamic> json) => FeeReport(
      (json['channel_fees'] as List<dynamic>)
          .map((e) => ChannelFeeReport.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['day_fee_sum'] as String,
      json['week_fee_sum'] as String,
      json['month_fee_sum'] as String,
    );

Map<String, dynamic> _$FeeReportToJson(FeeReport instance) => <String, dynamic>{
      'channel_fees': instance.channelFees,
      'day_fee_sum': instance.dayFeeSum,
      'week_fee_sum': instance.weekFeeSum,
      'month_fee_sum': instance.monthFeeSum,
    };
