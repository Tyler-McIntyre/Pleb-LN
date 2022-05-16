// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      json['payment_request'] as String,
      timeoutSeconds: json['timeout_seconds'] as int? ?? 60,
      allowSelfPayment: json['allow_self_payment'] as bool? ?? true,
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'payment_request': instance.paymentRequest,
      'timeout_seconds': instance.timeoutSeconds,
      'allow_self_payment': instance.allowSelfPayment,
    };
