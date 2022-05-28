// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_channel_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenChannelStream _$OpenChannelStreamFromJson(Map<String, dynamic> json) =>
    OpenChannelStream(
      json['private'] as bool,
      json['local_funding_amount'] as String,
      (json['node_pubkey'] as List<dynamic>).map((e) => e as int).toList(),
      json['min_confs'] as int?,
      json['sat_per_vbyte'] as String,
      json['spend_unconfirmed'] as bool,
    );

Map<String, dynamic> _$OpenChannelStreamToJson(OpenChannelStream instance) =>
    <String, dynamic>{
      'private': instance.private,
      'local_funding_amount': instance.localFundingAmount,
      'node_pubkey': instance.nodePubkey,
      'min_confs': instance.minConfs,
      'sat_per_vbyte': instance.satPerVbyte,
      'spend_unconfirmed': instance.spendUnconfirmed,
    };
