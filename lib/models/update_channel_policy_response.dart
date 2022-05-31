import 'package:json_annotation/json_annotation.dart';
import 'failed_update.dart';

part 'update_channel_policy_response.g.dart';

@JsonSerializable()
class UpdateChannelPolicyResponse {
  @JsonKey(name: 'failed_updates')
  List<FailedUpdate>? failedUpdates;

  UpdateChannelPolicyResponse(
    this.failedUpdates,
  );

  factory UpdateChannelPolicyResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateChannelPolicyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateChannelPolicyResponseToJson(this);
}
