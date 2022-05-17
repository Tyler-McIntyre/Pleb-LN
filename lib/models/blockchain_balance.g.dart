// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blockchain_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockchainBalance _$BlockchainBalanceFromJson(Map<String, dynamic> json) =>
    BlockchainBalance(
      json['total_balance'] as String,
      json['confirmed_balance'] as String?,
      json['unconfirmed_balance'] as String?,
      json['locked_balance'] as String?,
    );

Map<String, dynamic> _$BlockchainBalanceToJson(BlockchainBalance instance) =>
    <String, dynamic>{
      'total_balance': instance.totalBalance,
      'confirmed_balance': instance.confirmedBalance,
      'unconfirmed_balance': instance.unconfirmedBalance,
      'locked_balance': instance.lockedBalance,
    };
