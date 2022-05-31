// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_fee_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelFeeReport _$ChannelFeeReportFromJson(Map<String, dynamic> json) =>
    ChannelFeeReport(
      json['chan_id'] as String,
      json['channel_point'] as String,
      json['base_fee_msat'] as String,
      json['fee_per_mil'] as String,
      (json['fee_rate'] as num).toDouble(),
    );

Map<String, dynamic> _$ChannelFeeReportToJson(ChannelFeeReport instance) =>
    <String, dynamic>{
      'chan_id': instance.chanId,
      'channel_point': instance.channelPoint,
      'base_fee_msat': instance.baseFeeMsat,
      'fee_per_mil': instance.feePerMil,
      'fee_rate': instance.feeRate,
    };
