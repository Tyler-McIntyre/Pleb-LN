import 'package:json_annotation/json_annotation.dart';
part 'payment.g.dart';

/// [InvoiceRequest] and [Invoice] are distinct models because different elements
/// are optional depending on whether or not you are creating and receiving an
/// invoice.  They can contain the same information.
@JsonSerializable()
class Payment {
  @JsonKey(name: 'payment_request')
  String paymentRequest;

  @JsonKey(name: 'timeout_seconds')
  int? timeoutSeconds;

  @JsonKey(name: 'allow_self_payment')
  bool allowSelfPayment;

  Payment(this.paymentRequest,
      {this.timeoutSeconds = 60, this.allowSelfPayment = true});

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
