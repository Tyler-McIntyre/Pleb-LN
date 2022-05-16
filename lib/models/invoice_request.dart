import 'package:json_annotation/json_annotation.dart';

part 'invoice_request.g.dart';

/// [InvoiceRequest] and [Invoice] are distinct models because different elements
/// are optional depending on whether or not you are creating and receiving an
/// invoice.  They can contain the same information.
@JsonSerializable()
class InvoiceRequest {
  String value;
  String? memo;

  InvoiceRequest(this.value, {this.memo});

  factory InvoiceRequest.fromJson(Map<String, dynamic> json) =>
      _$InvoiceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceRequestToJson(this);
}
