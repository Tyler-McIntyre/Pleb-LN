// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
      json['active'] as bool,
      json['remote_pubkey'] as String,
      json['channel_point'] as String,
      json['chan_id'] as String,
      json['capacity'] as String,
      json['local_balance'] as String,
      json['remote_balance'] as String,
      json['commit_fee'] as String,
      json['commit_weight'] as String,
      json['fee_per_kw'] as String,
      json['unsettled_balance'] as String,
      json['total_satoshis_sent'] as String,
      json['total_satoshis_received'] as String,
      json['num_updates'] as String,
      json['private'] as bool,
      json['initiator'] as bool,
      json['chan_status_flags'] as String,
      json['lifetime'] as String,
      json['uptime'] as String,
      json['close_address'] as String,
      json['push_amount_sat'] as String,
      json['thaw_height'] as int,
    );

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
      'active': instance.active,
      'remote_pubkey': instance.remotePubkey,
      'channel_point': instance.channelPoint,
      'chan_id': instance.chanId,
      'capacity': instance.capacity,
      'local_balance': instance.localBalance,
      'remote_balance': instance.remoteBalance,
      'commit_fee': instance.commitFee,
      'commit_weight': instance.commitWeight,
      'fee_per_kw': instance.feePerKw,
      'unsettled_balance': instance.unsettledBalance,
      'total_satoshis_sent': instance.totalSatoshisSent,
      'total_satoshis_received': instance.totalSatoshisReceived,
      'num_updates': instance.numUpdates,
      'private': instance.private,
      'initiator': instance.initiator,
      'chan_status_flags': instance.chanStatusFlags,
      'lifetime': instance.lifetime,
      'uptime': instance.uptime,
      'close_address': instance.closeAddress,
      'push_amount_sat': instance.pushAmountSat,
      'thaw_height': instance.thawHeight,
    };
