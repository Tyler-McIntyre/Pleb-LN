import 'package:json_annotation/json_annotation.dart';

part 'out_point.g.dart';

@JsonSerializable()
class OutPoint {
  @JsonKey(name: 'txid_bytes')
  List<int> txidBytes;
  @JsonKey(name: 'txid_str')
  String txidStr;
  @JsonKey(name: 'output_index')
  int outputIndex;

  OutPoint(
    this.txidBytes,
    this.txidStr,
    this.outputIndex,
  );

  factory OutPoint.fromJson(Map<String, dynamic> json) =>
      _$OutPointFromJson(json);

  Map<String, dynamic> toJson() => _$OutPointToJson(this);
}
