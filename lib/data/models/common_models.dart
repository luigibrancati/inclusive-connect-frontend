import 'package:json_annotation/json_annotation.dart';

part 'common_models.g.dart';

@JsonSerializable()
class InviteCode {
  final String code;
  final int organizationId;
  final String createdAt;
  final String? expiresAt;
  final int? maxUses;
  final int currentUses;
  final bool isValid;

  InviteCode({
    required this.code,
    required this.organizationId,
    required this.createdAt,
    this.expiresAt,
    this.maxUses,
    this.currentUses = 0,
    this.isValid = true,
  });

  factory InviteCode.fromJson(Map<String, dynamic> json) =>
      _$InviteCodeFromJson(json);
  Map<String, dynamic> toJson() => _$InviteCodeToJson(this);
}

@JsonSerializable()
class LocationData {
  final String street;
  final int streetNumber;
  final String city;
  final int postalCode;
  final String province;
  final String country;

  LocationData({
    required this.street,
    required this.streetNumber,
    required this.city,
    required this.postalCode,
    required this.province,
    required this.country,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDataToJson(this);

  String formatted_address() {
    return '$street $streetNumber, $city, $province, $country';
  }
}
