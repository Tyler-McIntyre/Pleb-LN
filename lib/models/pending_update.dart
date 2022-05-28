import 'package:json_annotation/json_annotation.dart';

part 'pending_update.g.dart';

@JsonSerializable()
class PendingUpdate {
  @JsonKey(name: 'txid')
  List<int> txid;
  @JsonKey(name: 'output_index')
  int outputIndex;

  PendingUpdate(
    this.txid,
    this.outputIndex,
  );

  factory PendingUpdate.fromJson(Map<String, dynamic> json) =>
      _$PendingUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$PendingUpdateToJson(this);
}
