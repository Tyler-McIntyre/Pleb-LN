import 'package:json_annotation/json_annotation.dart';
part 'blockchain_balance.g.dart';

@JsonSerializable(explicitToJson: true)
class BlockchainBalance {
  BlockchainBalance(this.totalBalance, this.confirmedBalance,
      this.unconfirmedBalance, this.lockedBalance);

  @JsonKey(name: 'total_balance')
  String totalBalance;

  @JsonKey(name: 'confirmed_balance')
  String? confirmedBalance;

  @JsonKey(name: 'unconfirmed_balance')
  String? unconfirmedBalance;

  @JsonKey(name: 'locked_balance')
  String? lockedBalance;

  factory BlockchainBalance.fromJson(Map<String, dynamic> json) =>
      _$BlockchainBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$BlockchainBalanceToJson(this);
}
