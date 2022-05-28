import 'package:json_annotation/json_annotation.dart';
part 'channel_point.g.dart';

@JsonSerializable(explicitToJson: true)
class ChannelPoint {
  @JsonKey(name: 'funding_txid_bytes')
  List<int> fundingTxidBytes;
  @JsonKey(name: 'funding_txid_str')
  String fundingTxidStr;
  @JsonKey(name: 'output_index')
  int outputIndex;

  ChannelPoint(
    this.fundingTxidBytes,
    this.fundingTxidStr,
    this.outputIndex,
  );

  factory ChannelPoint.fromJson(Map<String, dynamic> json) =>
      _$ChannelPointFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelPointToJson(this);
}
