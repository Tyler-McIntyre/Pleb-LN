// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channels.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channels _$ChannelsFromJson(Map<String, dynamic> json) => Channels(
      (json['channels'] as List<dynamic>)
          .map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChannelsToJson(Channels instance) => <String, dynamic>{
      'channels': instance.channels.map((e) => e.toJson()).toList(),
    };
