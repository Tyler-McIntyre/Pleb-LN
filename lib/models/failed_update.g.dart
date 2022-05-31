// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'failed_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FailedUpdate _$FailedUpdateFromJson(Map<String, dynamic> json) => FailedUpdate(
      OutPoint.fromJson(json['outpoint'] as Map<String, dynamic>),
      $enumDecode(_$UpdateFailureEnumMap, json['reason']),
      json['update_error'] as String,
    );

Map<String, dynamic> _$FailedUpdateToJson(FailedUpdate instance) =>
    <String, dynamic>{
      'outpoint': instance.outpoint,
      'reason': _$UpdateFailureEnumMap[instance.reason],
      'update_error': instance.updateError,
    };

const _$UpdateFailureEnumMap = {
  UpdateFailure.UPDATE_FAILURE_UNKNOWN: 'UPDATE_FAILURE_UNKNOWN',
  UpdateFailure.UPDATE_FAILURE_PENDING: 'UPDATE_FAILURE_PENDING',
  UpdateFailure.UPDATE_FAILURE_NOT_FOUND: 'UPDATE_FAILURE_NOT_FOUND',
  UpdateFailure.UPDATE_FAILURE_INTERNAL_ERR: 'UPDATE_FAILURE_INTERNAL_ERR',
  UpdateFailure.UPDATE_FAILURE_INVALID_PARAMETER:
      'UPDATE_FAILURE_INVALID_PARAMETER',
};
