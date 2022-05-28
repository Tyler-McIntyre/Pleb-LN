import 'package:json_annotation/json_annotation.dart';

part 'accept_open_channel.g.dart';

@JsonSerializable()
class AcceptOpenChannel {
  @JsonKey(name: 'accept')
  bool accept;

  @JsonKey(name: 'pending_chan_id')
  List<int> pendingChanId;

  AcceptOpenChannel(
    this.accept,
    this.pendingChanId,
  );

  factory AcceptOpenChannel.fromJson(Map<String, dynamic> json) =>
      _$AcceptOpenChannelFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptOpenChannelToJson(this);
}
