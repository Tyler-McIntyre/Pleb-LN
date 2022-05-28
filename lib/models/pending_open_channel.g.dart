// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_open_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingOpenChannel _$PendingOpenChannelFromJson(Map<String, dynamic> json) =>
    PendingOpenChannel(
      PendingChannel.fromJson(json['channel'] as Map<String, dynamic>),
      json['commit_fee'] as String,
      json['commit_weight'] as String,
      json['fee_per_kw'] as String,
    );

Map<String, dynamic> _$PendingOpenChannelToJson(PendingOpenChannel instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'commit_fee': instance.commitFee,
      'commit_weight': instance.commitWeight,
      'fee_per_kw': instance.feePerKw,
    };
