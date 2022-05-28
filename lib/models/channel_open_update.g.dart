// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_open_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelOpenUpdate _$ChannelOpenUpdateFromJson(Map<String, dynamic> json) =>
    ChannelOpenUpdate(
      ChannelPoint.fromJson(json['channel_point'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChannelOpenUpdateToJson(ChannelOpenUpdate instance) =>
    <String, dynamic>{
      'channel_point': instance.channelPoint,
    };
