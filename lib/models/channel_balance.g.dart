// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelBalance _$ChannelBalanceFromJson(Map<String, dynamic> json) =>
    ChannelBalance(
      json['balance'] as String,
      json['pending_open_balance'] as String,
      Amount.fromJson(json['local_balance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChannelBalanceToJson(ChannelBalance instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'pending_open_balance': instance.pendingOpenBalance,
      'local_balance': instance.localBalance.toJson(),
    };
