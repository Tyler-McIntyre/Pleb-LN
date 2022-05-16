// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
      json['payment_request'] as String,
      json['r_hash'] as String,
      json['add_index'] as String,
      json['payment_addr'] as String,
      memo: json['memo'] as String?,
      value: json['value'] as String?,
      settled: json['settled'] as bool?,
    );

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
      'memo': instance.memo,
      'value': instance.value,
      'r_hash': instance.rHash,
      'add_index': instance.addIndex,
      'payment_addr': instance.paymentAddress,
      'payment_request': instance.paymentRequest,
      'settled': instance.settled,
    };
