// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_channel_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenChannelResponse _$OpenChannelResponseFromJson(Map<String, dynamic> json) =>
    OpenChannelResponse(
      json['funding_txid_bytes'] as String,
      json['funding_txid_str'] as String,
      json['output_index'] as int,
    );

Map<String, dynamic> _$OpenChannelResponseToJson(
        OpenChannelResponse instance) =>
    <String, dynamic>{
      'funding_txid_bytes': instance.fundingTxidBytes,
      'funding_txid_str': instance.fundingTxidStr,
      'output_index': instance.outputIndex,
    };
