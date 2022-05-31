import 'package:json_annotation/json_annotation.dart';
import '../constants/update_failure.dart';
import 'out_point.dart';

part 'failed_update.g.dart';

@JsonSerializable()
class FailedUpdate {
  @JsonKey(name: 'outpoint')
  OutPoint outpoint;
  @JsonKey(name: 'reason')
  UpdateFailure reason;
  @JsonKey(name: 'update_error')
  String updateError;

  FailedUpdate(
    this.outpoint,
    this.reason,
    this.updateError,
  );

  factory FailedUpdate.fromJson(Map<String, dynamic> json) =>
      _$FailedUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$FailedUpdateToJson(this);
}
