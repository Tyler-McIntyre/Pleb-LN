// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_open_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptOpenChannel _$AcceptOpenChannelFromJson(Map<String, dynamic> json) =>
    AcceptOpenChannel(
      json['accept'] as bool,
      (json['pending_chan_id'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$AcceptOpenChannelToJson(AcceptOpenChannel instance) =>
    <String, dynamic>{
      'accept': instance.accept,
      'pending_chan_id': instance.pendingChanId,
    };
