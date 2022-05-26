import 'package:json_annotation/json_annotation.dart';

part 'payment_request.g.dart';

@JsonSerializable()
class PaymentRequest {
  @JsonKey(name: 'num_satoshis')
  String num_satoshis;
  @JsonKey(name: 'expiry')
  String expiry;
  @JsonKey(name: 'description')
  String description;
  @JsonKey(name: 'num_msat')
  String num_msat;
  @JsonKey(name: 'timestamp')
  String timestamp;

  PaymentRequest(this.num_satoshis, this.expiry, this.description,
      this.num_msat, this.timestamp);

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}
