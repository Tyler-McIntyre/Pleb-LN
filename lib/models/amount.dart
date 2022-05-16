import 'package:json_annotation/json_annotation.dart';

part 'amount.g.dart';

@JsonSerializable()
class Amount {
  Amount(this.sat, this.mSat);
  @JsonKey(name: 'sat')
  String sat;

  @JsonKey(name: 'msat')
  String mSat;

  factory Amount.fromJson(Map<String, dynamic> json) => _$AmountFromJson(json);

  Map<String, dynamic> toJson() => _$AmountToJson(this);
}
