import 'package:json_annotation/json_annotation.dart';

part 'invoice.g.dart';

@JsonSerializable()
class Invoice {
  String? memo;
  String? value;

  @JsonKey(name: 'r_hash')
  String rHash;

  @JsonKey(name: 'add_index')
  String addIndex;

  @JsonKey(name: 'payment_addr')
  String paymentAddress;

  @JsonKey(name: 'payment_request')
  String paymentRequest;

  @JsonKey(name: 'settle_date')
  String settleDate;

  bool? settled;

  Invoice(
    this.paymentRequest,
    this.rHash,
    this.addIndex,
    this.paymentAddress,
    this.settleDate, {
    this.memo,
    this.value,
    this.settled,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}
