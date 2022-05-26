// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utxos_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UTXOSRequest _$UTXOSRequestFromJson(Map<String, dynamic> json) => UTXOSRequest(
      json['min_confs'] as int,
      json['max_confs'] as int,
      json['account'] as String?,
      json['unconfirmed_only'] as bool,
    );

Map<String, dynamic> _$UTXOSRequestToJson(UTXOSRequest instance) =>
    <String, dynamic>{
      'min_confs': instance.minConfs,
      'max_confs': instance.maxConfs,
      'account': instance.account,
      'unconfirmed_only': instance.unconfirmed_only,
    };
