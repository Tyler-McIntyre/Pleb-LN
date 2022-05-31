import 'package:json_annotation/json_annotation.dart';
import 'channel_close_update.dart';
import 'pending_update.dart';

part 'close_channel_response.g.dart';

@JsonSerializable()
class CloseChannelResponse {
  @JsonKey(name: 'close_pending')
  PendingUpdate closePending;
  @JsonKey(name: 'chan_close')
  ChannelCloseUpdate chanClose;

  CloseChannelResponse(
    this.closePending,
    this.chanClose,
  );

  factory CloseChannelResponse.fromJson(Map<String, dynamic> json) =>
      _$CloseChannelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CloseChannelResponseToJson(this);
}
