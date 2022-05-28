import 'package:json_annotation/json_annotation.dart';

part 'ready_for_pbst_funding.g.dart';

@JsonSerializable()
class ReadyForPbstFunding {
  @JsonKey(name: 'funding_address')
  String fundingAddress;
  @JsonKey(name: 'funding_amount')
  String fundingAmount;
  @JsonKey(name: 'psbt')
  List<int> psbt;

  ReadyForPbstFunding(
    this.fundingAddress,
    this.fundingAmount,
    this.psbt,
  );

  factory ReadyForPbstFunding.fromJson(Map<String, dynamic> json) =>
      _$ReadyForPbstFundingFromJson(json);

  Map<String, dynamic> toJson() => _$ReadyForPbstFundingToJson(this);
}
