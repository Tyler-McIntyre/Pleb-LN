import 'package:json_annotation/json_annotation.dart';
part 'utxos_request.g.dart';

@JsonSerializable()
class UTXOSRequest {
  @JsonKey(name: 'min_confs')
  int minConfs;
  @JsonKey(name: 'max_confs')
  int maxConfs;
  @JsonKey(name: 'account')
  String? account;
  @JsonKey(name: 'unconfirmed_only')
  bool unconfirmed_only;

  UTXOSRequest(
      this.minConfs, this.maxConfs, this.account, this.unconfirmed_only);

  factory UTXOSRequest.fromJson(Map<String, dynamic> json) =>
      _$UTXOSRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UTXOSRequestToJson(this);
}
