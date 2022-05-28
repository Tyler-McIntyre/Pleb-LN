import 'package:json_annotation/json_annotation.dart';

part 'open_channel_stream.g.dart';

@JsonSerializable()
class OpenChannelStream {
  @JsonKey(name: 'private')
  bool private;
  @JsonKey(name: 'local_funding_amount')
  String localFundingAmount;
  @JsonKey(name: 'node_pubkey')
  List<int> nodePubkey;
  @JsonKey(name: 'min_confs')
  int? minConfs;
  @JsonKey(name: 'sat_per_vbyte')
  String satPerVbyte;
  @JsonKey(name: 'spend_unconfirmed')
  bool spendUnconfirmed;

  OpenChannelStream(
    this.private,
    this.localFundingAmount,
    this.nodePubkey,
    this.minConfs,
    this.satPerVbyte,
    this.spendUnconfirmed,
  );

  factory OpenChannelStream.fromJson(Map<String, dynamic> json) =>
      _$OpenChannelStreamFromJson(json);

  Map<String, dynamic> toJson() => _$OpenChannelStreamToJson(this);
}
