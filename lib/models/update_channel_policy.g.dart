// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_channel_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateChannelPolicy _$UpdateChannelPolicyFromJson(Map<String, dynamic> json) =>
    UpdateChannelPolicy(
      json['global'] as bool,
      ChannelPoint.fromJson(json['chan_point'] as Map<String, dynamic>),
      json['base_fee_msat'] as String,
      (json['fee_rate'] as num).toDouble(),
      timeLockDelta: json['time_lock_delta'] as int? ?? 18,
    );

Map<String, dynamic> _$UpdateChannelPolicyToJson(
        UpdateChannelPolicy instance) =>
    <String, dynamic>{
      'global': instance.global,
      'chan_point': instance.chanPoint,
      'base_fee_msat': instance.baseFeeMsat,
      'fee_rate': instance.feeRate,
      'time_lock_delta': instance.timeLockDelta,
    };
