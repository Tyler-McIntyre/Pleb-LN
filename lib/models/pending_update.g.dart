// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingUpdate _$PendingUpdateFromJson(Map<String, dynamic> json) =>
    PendingUpdate(
      (json['txid'] as List<dynamic>).map((e) => e as int).toList(),
      json['output_index'] as int,
    );

Map<String, dynamic> _$PendingUpdateToJson(PendingUpdate instance) =>
    <String, dynamic>{
      'txid': instance.txid,
      'output_index': instance.outputIndex,
    };
