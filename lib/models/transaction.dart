import 'package:json_annotation/json_annotation.dart';
part 'transaction.g.dart';

@JsonSerializable(explicitToJson: true)
class Transaction {
  Transaction(
      this.txHash,
      this.amount,
      this.numConfirmations,
      this.blockHash,
      this.blockHeight,
      this.timeStamp,
      this.totalFees,
      this.destAddresses,
      this.rawTxHex,
      {this.label});

  @JsonKey(name: 'tx_hash')
  String txHash;
  @JsonKey(name: 'amount')
  String amount;
  @JsonKey(name: 'num_confirmations')
  int numConfirmations;
  @JsonKey(name: 'block_hash')
  String blockHash;
  @JsonKey(name: 'block_height')
  int blockHeight;
  @JsonKey(name: 'time_stamp')
  String timeStamp;
  @JsonKey(name: 'total_fees')
  String totalFees;
  @JsonKey(name: 'dest_addresses')
  List<String> destAddresses;
  @JsonKey(name: 'raw_tx_hex')
  String rawTxHex;
  @JsonKey(name: 'label')
  String? label;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
