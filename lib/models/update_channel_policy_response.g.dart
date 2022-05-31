// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_channel_policy_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateChannelPolicyResponse _$UpdateChannelPolicyResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateChannelPolicyResponse(
      (json['failed_updates'] as List<dynamic>?)
          ?.map((e) => FailedUpdate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UpdateChannelPolicyResponseToJson(
        UpdateChannelPolicyResponse instance) =>
    <String, dynamic>{
      'failed_updates': instance.failedUpdates,
    };
