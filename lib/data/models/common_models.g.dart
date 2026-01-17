// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteCode _$InviteCodeFromJson(Map<String, dynamic> json) => InviteCode(
  code: json['code'] as String,
  organizationId: (json['organizationId'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  expiresAt: json['expiresAt'] as String?,
  maxUses: (json['maxUses'] as num?)?.toInt(),
  currentUses: (json['currentUses'] as num?)?.toInt() ?? 0,
  isValid: json['isValid'] as bool? ?? true,
);

Map<String, dynamic> _$InviteCodeToJson(InviteCode instance) =>
    <String, dynamic>{
      'code': instance.code,
      'organizationId': instance.organizationId,
      'createdAt': instance.createdAt,
      'expiresAt': instance.expiresAt,
      'maxUses': instance.maxUses,
      'currentUses': instance.currentUses,
      'isValid': instance.isValid,
    };

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
  street: json['street'] as String,
  streetNumber: (json['streetNumber'] as num).toInt(),
  city: json['city'] as String,
  postalCode: (json['postalCode'] as num).toInt(),
  province: json['province'] as String,
  country: json['country'] as String,
);

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'street': instance.street,
      'streetNumber': instance.streetNumber,
      'city': instance.city,
      'postalCode': instance.postalCode,
      'province': instance.province,
      'country': instance.country,
    };
