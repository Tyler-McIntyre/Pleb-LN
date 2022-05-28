import 'package:json_annotation/json_annotation.dart';

part 'accept_open_channel_response.g.dart';

@JsonSerializable()
class AcceptOpenChannelResponse {
  @JsonKey(name: 'node_pubkey')
  List<int> nodePubkey;

  @JsonKey(name: 'pending_chan_id')
  List<int> pendingChanId;

  @JsonKey(name: 'funding_amt')
  String fundingAmt;

  @JsonKey(name: 'dust_limit')
  String dustLimit;

  @JsonKey(name: 'channel_reserve')
  String channelReserve;

  @JsonKey(name: 'channel_flags')
  int channelFlags;

  AcceptOpenChannelResponse(
    this.nodePubkey,
    this.pendingChanId,
    this.fundingAmt,
    this.dustLimit,
    this.channelReserve,
    this.channelFlags,
  );

  factory AcceptOpenChannelResponse.fromJson(Map<String, dynamic> json) =>
      _$AcceptOpenChannelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptOpenChannelResponseToJson(this);
}
