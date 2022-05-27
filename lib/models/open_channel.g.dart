// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenChannel _$OpenChannelFromJson(Map<String, dynamic> json) => OpenChannel(
      json['private'] as bool,
      json['local_funding_amount'] as String,
      (json['node_pubkey'] as List<dynamic>).map((e) => e as int).toList(),
      satPerVbyte: json['sat_per_vbyte'] as String? ?? '0',
      spendUnconfirmed: json['spend_unconfirmed'] as bool? ?? false,
      minConfs: json['min_confs'] as int? ?? 3,
    );

Map<String, dynamic> _$OpenChannelToJson(OpenChannel instance) =>
    <String, dynamic>{
      'private': instance.private,
      'local_funding_amount': instance.localFundingAmount,
      'node_pubkey': instance.nodePubkey,
      'min_confs': instance.minConfs,
      'sat_per_vbyte': instance.satPerVbyte,
      'spend_unconfirmed': instance.spendUnconfirmed,
    };
