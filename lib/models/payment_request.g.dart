// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      json['num_satoshis'] as String,
      json['expiry'] as String,
      json['description'] as String,
      json['num_msat'] as String,
      json['timestamp'] as String,
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'num_satoshis': instance.num_satoshis,
      'expiry': instance.expiry,
      'description': instance.description,
      'num_msat': instance.num_msat,
      'timestamp': instance.timestamp,
    };
