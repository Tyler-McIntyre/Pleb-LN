// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_channels.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingChannels _$PendingChannelsFromJson(Map<String, dynamic> json) =>
    PendingChannels(
      json['total_limbo_balance'] as String,
      (json['pending_open_channels'] as List<dynamic>)
          .map((e) => PendingOpenChannel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PendingChannelsToJson(PendingChannels instance) =>
    <String, dynamic>{
      'total_limbo_balance': instance.totalLimboBalance,
      'pending_open_channels': instance.pendingOpenChannels,
    };
