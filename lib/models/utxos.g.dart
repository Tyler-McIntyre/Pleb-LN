// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utxos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UTXOS _$UTXOSFromJson(Map<String, dynamic> json) => UTXOS(
      (json['utxos'] as List<dynamic>)
          .map((e) => UTXO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UTXOSToJson(UTXOS instance) => <String, dynamic>{
      'utxos': instance.utxos,
    };
