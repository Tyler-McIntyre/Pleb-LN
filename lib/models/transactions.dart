import 'package:json_annotation/json_annotation.dart';

import 'transaction.dart';
part 'transactions.g.dart';

@JsonSerializable(explicitToJson: true)
class Transactions {
  Transactions(
    this.transactions,
  );

  @JsonKey(name: 'transactions')
  List<Transaction> transactions;

  factory Transactions.fromJson(Map<String, dynamic> json) =>
      _$TransactionsFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionsToJson(this);
}
