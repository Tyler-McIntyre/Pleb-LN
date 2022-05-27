import 'package:json_annotation/json_annotation.dart';
part 'open_channel_response.g.dart';

@JsonSerializable(explicitToJson: true)
class OpenChannelResponse {
  @JsonKey(name: 'funding_txid_bytes')
  String fundingTxidBytes;
  @JsonKey(name: 'funding_txid_str')
  String fundingTxidStr;
  @JsonKey(name: 'output_index')
  int outputIndex;

  OpenChannelResponse(
    this.fundingTxidBytes,
    this.fundingTxidStr,
    this.outputIndex,
  );

  factory OpenChannelResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenChannelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenChannelResponseToJson(this);
}
