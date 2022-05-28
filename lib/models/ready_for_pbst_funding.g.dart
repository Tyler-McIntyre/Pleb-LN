// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ready_for_pbst_funding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadyForPbstFunding _$ReadyForPbstFundingFromJson(Map<String, dynamic> json) =>
    ReadyForPbstFunding(
      json['funding_address'] as String,
      json['funding_amount'] as String,
      (json['psbt'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$ReadyForPbstFundingToJson(
        ReadyForPbstFunding instance) =>
    <String, dynamic>{
      'funding_address': instance.fundingAddress,
      'funding_amount': instance.fundingAmount,
      'psbt': instance.psbt,
    };
