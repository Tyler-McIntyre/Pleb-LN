import 'package:json_annotation/json_annotation.dart';
import 'channel_point.dart';

part 'channel_open_update.g.dart';

@JsonSerializable()
class ChannelOpenUpdate {
  @JsonKey(name: 'channel_point')
  ChannelPoint channelPoint;

  ChannelOpenUpdate(
    this.channelPoint,
  );

  factory ChannelOpenUpdate.fromJson(Map<String, dynamic> json) =>
      _$ChannelOpenUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelOpenUpdateToJson(this);
}
