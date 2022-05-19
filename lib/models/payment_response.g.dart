// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentResponse _$PaymentResponseFromJson(Map<String, dynamic> json) =>
    PaymentResponse(
      json['status'] as String,
      json['payment_hash'] as String,
      json['creation_time_ns'] as String,
      json['value_sat'] as String,
      json['fee_sat'] as String,
      json['payment_index'] as String,
    );

Map<String, dynamic> _$PaymentResponseToJson(PaymentResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'payment_hash': instance.paymentHash,
      'creation_time_ns': instance.creationTimeNanoSeconds,
      'value_sat': instance.valueSat,
      'fee_sat': instance.feeSat,
      'payment_index': instance.paymentIndex,
    };
