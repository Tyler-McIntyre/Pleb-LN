// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_open_channel_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptOpenChannelResponse _$AcceptOpenChannelResponseFromJson(
        Map<String, dynamic> json) =>
    AcceptOpenChannelResponse(
      (json['node_pubkey'] as List<dynamic>).map((e) => e as int).toList(),
      (json['pending_chan_id'] as List<dynamic>).map((e) => e as int).toList(),
      json['funding_amt'] as String,
      json['dust_limit'] as String,
      json['channel_reserve'] as String,
      json['channel_flags'] as int,
    );

Map<String, dynamic> _$AcceptOpenChannelResponseToJson(
        AcceptOpenChannelResponse instance) =>
    <String, dynamic>{
      'node_pubkey': instance.nodePubkey,
      'pending_chan_id': instance.pendingChanId,
      'funding_amt': instance.fundingAmt,
      'dust_limit': instance.dustLimit,
      'channel_reserve': instance.channelReserve,
      'channel_flags': instance.channelFlags,
    };
