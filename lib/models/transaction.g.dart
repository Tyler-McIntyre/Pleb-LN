// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      json['tx_hash'] as String,
      json['amount'] as String,
      json['num_confirmations'] as int,
      json['block_hash'] as String,
      json['block_height'] as int,
      json['time_stamp'] as String,
      json['total_fees'] as String,
      (json['dest_addresses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      json['raw_tx_hex'] as String,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'tx_hash': instance.txHash,
      'amount': instance.amount,
      'num_confirmations': instance.numConfirmations,
      'block_hash': instance.blockHash,
      'block_height': instance.blockHeight,
      'time_stamp': instance.timeStamp,
      'total_fees': instance.totalFees,
      'dest_addresses': instance.destAddresses,
      'raw_tx_hex': instance.rawTxHex,
      'label': instance.label,
    };
