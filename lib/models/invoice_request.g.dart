// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceRequest _$InvoiceRequestFromJson(Map<String, dynamic> json) =>
    InvoiceRequest(
      json['value'] as String,
      memo: json['memo'] as String?,
      expiry: json['expiry'] as String? ?? '3600',
    );

Map<String, dynamic> _$InvoiceRequestToJson(InvoiceRequest instance) =>
    <String, dynamic>{
      'value': instance.value,
      'memo': instance.memo,
      'expiry': instance.expiry,
    };
