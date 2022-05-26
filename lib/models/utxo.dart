import 'package:json_annotation/json_annotation.dart';
part 'utxo.g.dart';

@JsonSerializable()
class UTXO {
  // @JsonKey(name: 'address_type')
  // AddressType address_type;

  @JsonKey(name: 'amount_sat')
  String amountSat;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'pk_script')
  String pkScript;

  // @JsonKey(name: 'outpoint')
  // OutPoint outpoint;

  @JsonKey(name: 'confirmations')
  String confirmations;

  UTXO(this.address, this.amountSat, this.pkScript, this.confirmations);

  factory UTXO.fromJson(Map<String, dynamic> json) => _$UTXOFromJson(json);

  Map<String, dynamic> toJson() => _$UTXOToJson(this);
}
