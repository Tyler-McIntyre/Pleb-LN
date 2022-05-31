// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'out_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutPoint _$OutPointFromJson(Map<String, dynamic> json) => OutPoint(
      (json['txid_bytes'] as List<dynamic>).map((e) => e as int).toList(),
      json['txid_str'] as String,
      json['output_index'] as int,
    );

Map<String, dynamic> _$OutPointToJson(OutPoint instance) => <String, dynamic>{
      'txid_bytes': instance.txidBytes,
      'txid_str': instance.txidStr,
      'output_index': instance.outputIndex,
    };
