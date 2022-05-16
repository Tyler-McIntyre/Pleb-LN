// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Amount _$AmountFromJson(Map<String, dynamic> json) => Amount(
      json['sat'] as String,
      json['msat'] as String,
    );

Map<String, dynamic> _$AmountToJson(Amount instance) => <String, dynamic>{
      'sat': instance.sat,
      'msat': instance.mSat,
    };
