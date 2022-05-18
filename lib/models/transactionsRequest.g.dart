// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactionsRequest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionsRequest _$TransactionsRequestFromJson(Map<String, dynamic> json) =>
    TransactionsRequest(
      json['start_height'] as String,
      json['end_height'] as String,
      account: json['account'] as String?,
    );

Map<String, dynamic> _$TransactionsRequestToJson(
        TransactionsRequest instance) =>
    <String, dynamic>{
      'start_height': instance.startHeight,
      'end_height': instance.endHeight,
      'account': instance.account,
    };
