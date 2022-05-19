// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payments _$PaymentsFromJson(Map<String, dynamic> json) => Payments(
      (json['payments'] as List<dynamic>)
          .map((e) => PaymentResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['total_num_payments'] as String?,
      firstIndexOffset: json['first_index_offset'] as String?,
      lastIndexOffset: json['last_index_offset'] as String?,
    );

Map<String, dynamic> _$PaymentsToJson(Payments instance) => <String, dynamic>{
      'payments': instance.payments,
      'first_index_offset': instance.firstIndexOffset,
      'last_index_offset': instance.lastIndexOffset,
      'total_num_payments': instance.totalNumPayments,
    };
