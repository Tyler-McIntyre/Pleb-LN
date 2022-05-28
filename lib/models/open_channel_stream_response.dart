import 'package:json_annotation/json_annotation.dart';
import 'channel_open_update.dart';
import 'pending_update.dart';
import 'ready_for_pbst_funding.dart';

part 'open_channel_stream_response.g.dart';

@JsonSerializable()
class OpenChannelStreamResponse {
  @JsonKey(name: 'chan_pending')
  PendingUpdate chanPending;
  @JsonKey(name: 'chan_open')
  ChannelOpenUpdate chanOpen;
  @JsonKey(name: 'psbt_fund')
  ReadyForPbstFunding psbtFund;
  @JsonKey(name: 'pending_chan_id')
  List<int> pending_chan_id;

  OpenChannelStreamResponse(
      this.chanPending, this.chanOpen, this.psbtFund, this.pending_chan_id);

  factory OpenChannelStreamResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenChannelStreamResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenChannelStreamResponseToJson(this);
}
