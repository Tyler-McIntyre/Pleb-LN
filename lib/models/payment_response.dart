import 'package:json_annotation/json_annotation.dart';

part 'payment_response.g.dart';

@JsonSerializable()
class PaymentResponse {
  @JsonKey(name: 'status')
  String status;
  @JsonKey(name: 'payment_hash')
  String paymentHash;
  @JsonKey(name: 'creation_time_ns')
  String creationTimeNanoSeconds;
  @JsonKey(name: 'value_sat')
  String valueSat;
  @JsonKey(name: 'fee_sat')
  String feeSat;
  @JsonKey(name: 'payment_index')
  String paymentIndex;

  PaymentResponse(this.status, this.paymentHash, this.creationTimeNanoSeconds,
      this.valueSat, this.feeSat, this.paymentIndex);

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);
}
