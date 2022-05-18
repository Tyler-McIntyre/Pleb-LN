import 'package:json_annotation/json_annotation.dart';
part 'transactionsRequest.g.dart';

@JsonSerializable(explicitToJson: true)
class TransactionsRequest {
  TransactionsRequest(
    this.startHeight,
    this.endHeight, {
    this.account,
  });

  @JsonKey(name: 'start_height')
  String startHeight;

  @JsonKey(name: 'end_height')
  String endHeight;

  @JsonKey(name: 'account')
  String? account;

  factory TransactionsRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionsRequestToJson(this);
}
