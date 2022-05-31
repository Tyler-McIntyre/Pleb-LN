// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'close_channel_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloseChannelResponse _$CloseChannelResponseFromJson(
        Map<String, dynamic> json) =>
    CloseChannelResponse(
      PendingUpdate.fromJson(json['close_pending'] as Map<String, dynamic>),
      ChannelCloseUpdate.fromJson(json['chan_close'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CloseChannelResponseToJson(
        CloseChannelResponse instance) =>
    <String, dynamic>{
      'close_pending': instance.closePending,
      'chan_close': instance.chanClose,
    };
