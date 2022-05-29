// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingChannel _$PendingChannelFromJson(Map<String, dynamic> json) =>
    PendingChannel(
      json['remote_node_pub'] as String,
      json['channel_point'] as String,
      json['capacity'] as String,
      json['local_balance'] as String,
      json['remote_balance'] as String,
      json['local_chan_reserve_sat'] as String,
      json['remote_chan_reserve_sat'] as String,
      json['private'] as bool?,
    );

Map<String, dynamic> _$PendingChannelToJson(PendingChannel instance) =>
    <String, dynamic>{
      'remote_node_pub': instance.remoteNodePub,
      'channel_point': instance.channelPoint,
      'capacity': instance.capacity,
      'local_balance': instance.localBalance,
      'remote_balance': instance.remoteBalance,
      'local_chan_reserve_sat': instance.localChanReserveSat,
      'remote_chan_reserve_sat': instance.remoteChanReserveSat,
      'private': instance.private,
    };
