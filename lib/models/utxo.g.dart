// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utxo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UTXO _$UTXOFromJson(Map<String, dynamic> json) => UTXO(
      json['address'] as String,
      json['amount_sat'] as String,
      json['pk_script'] as String,
      json['confirmations'] as String,
    );

Map<String, dynamic> _$UTXOToJson(UTXO instance) => <String, dynamic>{
      'amount_sat': instance.amountSat,
      'address': instance.address,
      'pk_script': instance.pkScript,
      'confirmations': instance.confirmations,
    };
