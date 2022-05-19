import 'package:json_annotation/json_annotation.dart';

import 'invoice.dart';
part 'invoices.g.dart';

/// [InvoiceRequest] and [Invoice] are distinct models because different elements
/// are optional depending on whether or not you are creating and receiving an
/// invoice.  They can contain the same information.
@JsonSerializable()
class Invoices {
  @JsonKey(name: 'invoices')
  List<Invoice> invoices;

  @JsonKey(name: 'first_index_offset')
  String? firstIndexOffset;

  @JsonKey(name: 'last_index_offset')
  String? lastIndexOffset;

  Invoices(this.invoices, {this.firstIndexOffset, this.lastIndexOffset});

  factory Invoices.fromJson(Map<String, dynamic> json) =>
      _$InvoicesFromJson(json);

  Map<String, dynamic> toJson() => _$InvoicesToJson(this);
}
