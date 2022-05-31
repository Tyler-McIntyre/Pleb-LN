import 'package:json_annotation/json_annotation.dart';

part 'channel_close_update.g.dart';

@JsonSerializable()
class ChannelCloseUpdate {
  @JsonKey(name: 'closing_txid')
  List<int> closingTxid;
  @JsonKey(name: 'success')
  bool success;

  ChannelCloseUpdate(
    this.closingTxid,
    this.success,
  );

  factory ChannelCloseUpdate.fromJson(Map<String, dynamic> json) =>
      _$ChannelCloseUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelCloseUpdateToJson(this);
}
