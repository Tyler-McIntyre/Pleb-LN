import 'package:firebolt/models/payment_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payments.g.dart';

@JsonSerializable()
class Payments {
  @JsonKey(name: 'payments')
  List<PaymentResponse> payments;

  @JsonKey(name: 'first_index_offset')
  String? firstIndexOffset;

  @JsonKey(name: 'last_index_offset')
  String? lastIndexOffset;

  @JsonKey(name: 'total_num_payments')
  String? totalNumPayments;

  Payments(this.payments, this.totalNumPayments,
      {this.firstIndexOffset, this.lastIndexOffset});

  factory Payments.fromJson(Map<String, dynamic> json) =>
      _$PaymentsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentsToJson(this);
}
