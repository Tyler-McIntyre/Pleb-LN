// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelPoint _$ChannelPointFromJson(Map<String, dynamic> json) => ChannelPoint(
      (json['funding_txid_bytes'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      json['funding_txid_str'] as String,
      json['output_index'] as int,
    );

Map<String, dynamic> _$ChannelPointToJson(ChannelPoint instance) =>
    <String, dynamic>{
      'funding_txid_bytes': instance.fundingTxidBytes,
      'funding_txid_str': instance.fundingTxidStr,
      'output_index': instance.outputIndex,
    };
