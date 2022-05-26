import 'package:firebolt/models/utxo.dart';
import 'package:json_annotation/json_annotation.dart';
part 'utxos.g.dart';

@JsonSerializable()
class UTXOS {
  @JsonKey(name: 'utxos')
  List<UTXO> utxos;

  UTXOS(this.utxos);

  factory UTXOS.fromJson(Map<String, dynamic> json) => _$UTXOSFromJson(json);

  Map<String, dynamic> toJson() => _$UTXOSToJson(this);
}
