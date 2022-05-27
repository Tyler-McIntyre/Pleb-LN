import 'package:json_annotation/json_annotation.dart';
part 'open_channel.g.dart';

@JsonSerializable(explicitToJson: true)
class OpenChannel {
  @JsonKey(name: 'private')
  bool private;
  @JsonKey(name: 'local_funding_amount')
  String localFundingAmount;
  @JsonKey(name: 'node_pubkey')
  List<int> nodePubkey;
  @JsonKey(name: 'min_confs')
  int minConfs;
  @JsonKey(name: 'sat_per_vbyte')
  String satPerVbyte;
  @JsonKey(name: 'spend_unconfirmed')
  bool spendUnconfirmed;
  // @JsonKey(name: 'node_pubkey_string')
  // String nodePubkeyString;
  // @JsonKey(name: 'push_sat')
  // String pushSat;
  // @JsonKey(name: 'target_conf')
  // int targetConf;
  // @JsonKey(name: 'min_htlc_msat')
  // String minHtlcMsat;
  // @JsonKey(name: 'remote_csv_delay')
  // int remoteCsvDelay;
  // @JsonKey(name: 'close_address')
  // String closeAddress;
  // @JsonKey(name: 'funding_shim')
  // FundingShim fundingShim;
  // @JsonKey(name: 'remote_max_value_in_flight_msat')
  // String remoteMaxValueInFlightMsat;
  // @JsonKey(name: 'remote_max_htlcs')
  // int remoteMaxHtlcs;
  // @JsonKey(name: 'max_local_csv')
  // int maxLocalCsv;
  // @JsonKey(name: 'commitment_type')
  // CommitmentType commitmentType;

  OpenChannel(
    this.private,
    this.localFundingAmount,
    this.nodePubkey, {
    this.satPerVbyte = '0',
    this.spendUnconfirmed = false,
    this.minConfs = 3,
  });

  factory OpenChannel.fromJson(Map<String, dynamic> json) =>
      _$OpenChannelFromJson(json);

  Map<String, dynamic> toJson() => _$OpenChannelToJson(this);
}
