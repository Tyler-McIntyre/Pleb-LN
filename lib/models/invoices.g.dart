// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoices _$InvoicesFromJson(Map<String, dynamic> json) => Invoices(
      (json['invoices'] as List<dynamic>)
          .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstIndexOffset: json['first_index_offset'] as String?,
      lastIndexOffset: json['last_index_offset'] as String?,
    );

Map<String, dynamic> _$InvoicesToJson(Invoices instance) => <String, dynamic>{
      'invoices': instance.invoices,
      'first_index_offset': instance.firstIndexOffset,
      'last_index_offset': instance.lastIndexOffset,
    };
