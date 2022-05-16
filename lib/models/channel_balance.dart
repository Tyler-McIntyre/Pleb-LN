import 'package:json_annotation/json_annotation.dart';
import 'amount.dart';
part 'channel_balance.g.dart';

@JsonSerializable(explicitToJson: true)
class ChannelBalance {
  ChannelBalance(this.balance, this.pendingOpenBalance, this.localBalance);

  String balance;

  @JsonKey(name: 'pending_open_balance')
  String pendingOpenBalance;

  @JsonKey(name: 'local_balance')
  Amount localBalance;

  factory ChannelBalance.fromJson(Map<String, dynamic> json) =>
      _$ChannelBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelBalanceToJson(this);
}
