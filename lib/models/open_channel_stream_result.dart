import 'package:json_annotation/json_annotation.dart';
import 'open_channel_stream_response.dart';

part 'open_channel_stream_result.g.dart';

@JsonSerializable()
class OpenChannelStreamResult {
  @JsonKey(name: 'result')
  OpenChannelStreamResponse result;

  OpenChannelStreamResult(
    this.result,
  );

  factory OpenChannelStreamResult.fromJson(Map<String, dynamic> json) =>
      _$OpenChannelStreamResultFromJson(json);

  Map<String, dynamic> toJson() => _$OpenChannelStreamResultToJson(this);
}
