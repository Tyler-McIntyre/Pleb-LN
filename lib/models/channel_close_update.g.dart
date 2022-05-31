// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_close_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelCloseUpdate _$ChannelCloseUpdateFromJson(Map<String, dynamic> json) =>
    ChannelCloseUpdate(
      (json['closing_txid'] as List<dynamic>).map((e) => e as int).toList(),
      json['success'] as bool,
    );

Map<String, dynamic> _$ChannelCloseUpdateToJson(ChannelCloseUpdate instance) =>
    <String, dynamic>{
      'closing_txid': instance.closingTxid,
      'success': instance.success,
    };
