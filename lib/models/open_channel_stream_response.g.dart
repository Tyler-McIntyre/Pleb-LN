// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_channel_stream_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenChannelStreamResponse _$OpenChannelStreamResponseFromJson(
        Map<String, dynamic> json) =>
    OpenChannelStreamResponse(
      PendingUpdate.fromJson(json['chan_pending'] as Map<String, dynamic>),
      ReadyForPbstFunding.fromJson(json['psbt_fund'] as Map<String, dynamic>),
      (json['pending_chan_id'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$OpenChannelStreamResponseToJson(
        OpenChannelStreamResponse instance) =>
    <String, dynamic>{
      'chan_pending': instance.chanPending,
      'psbt_fund': instance.psbtFund,
      'pending_chan_id': instance.pending_chan_id,
    };
