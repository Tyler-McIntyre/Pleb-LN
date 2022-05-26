import 'package:json_annotation/json_annotation.dart';
import 'channel.dart';
part 'channels.g.dart';

@JsonSerializable(explicitToJson: true)
class Channels {
  @JsonKey(name: 'channels')
  List<Channel> channels;

  Channels(
    this.channels,
  );

  factory Channels.fromJson(Map<String, dynamic> json) =>
      _$ChannelsFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelsToJson(this);
}
