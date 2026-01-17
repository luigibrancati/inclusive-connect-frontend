import 'package:json_annotation/json_annotation.dart';
import 'common_models.dart';

part 'user_models.g.dart';

enum UserType {
  @JsonValue('member')
  member,
  @JsonValue('organization')
  organization,
}

@JsonSerializable()
class FiscalData {
  final String fiscalCode;
  final String vatNumber;
  final String? atecoCode;

  FiscalData({
    required this.fiscalCode,
    required this.vatNumber,
    this.atecoCode,
  });

  factory FiscalData.fromJson(Map<String, dynamic> json) =>
      _$FiscalDataFromJson(json);
  Map<String, dynamic> toJson() => _$FiscalDataToJson(this);
}

@JsonSerializable()
class UserReference {
  final int userId;
  final UserType userType;

  UserReference({required this.userId, required this.userType});

  factory UserReference.fromJson(Map<String, dynamic> json) =>
      _$UserReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$UserReferenceToJson(this);
}

@JsonSerializable()
class ContentAuthorPublic extends UserReference {
  final String username;
  final String? profilePicUrl;
  // final String? profilePicPresignedUrl;

  ContentAuthorPublic({
    required super.userId,
    required super.userType,
    required this.username,
    this.profilePicUrl,
    // this.profilePicPresignedUrl,
  });

  factory ContentAuthorPublic.fromJson(Map<String, dynamic> json) =>
      _$ContentAuthorPublicFromJson(json);
  Map<String, dynamic> toJson() => _$ContentAuthorPublicToJson(this);
}

@JsonSerializable()
class UserCreate {
  final String username;
  final String email;
  final String password;
  final UserType userType;
  final String? bio;
  String? inviteCode;
  int? organizationId;
  LocationData? residentialData;
  FiscalData? fiscalData;

  UserCreate({
    required this.username,
    required this.email,
    required this.password,
    required this.userType,
    this.bio,
    this.inviteCode,
    this.organizationId,
    this.residentialData,
    this.fiscalData,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) =>
      _$UserCreateFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateToJson(this);
}

// Common interface or base class could be useful, but keeping it simple for now as they have different fields.
@JsonSerializable()
class UserPublic extends UserReference {
  final String username;
  final String email;
  final String? profilePicUrl;
  final String? bio;
  // final String? profilePicPresignedUrl;
  // Member
  String? inviteCode;
  int? organizationId;
  // Org
  LocationData? residentialData;
  FiscalData? fiscalData;
  final String createdAt;
  final String lastModifiedAt;

  UserPublic({
    required super.userId,
    required super.userType,
    required this.username,
    required this.email,
    this.profilePicUrl,
    this.bio,
    // this.profilePicPresignedUrl,
    this.inviteCode,
    this.organizationId,
    this.residentialData,
    this.fiscalData,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  factory UserPublic.fromJson(Map<String, dynamic> json) =>
      _$UserPublicFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$UserPublicToJson(this);

  UserPublic copyWith({
    String? username,
    String? email,
    String? profilePicUrl,
    String? bio,
    String? inviteCode,
    int? organizationId,
    LocationData? residentialData,
    FiscalData? fiscalData,
    String? lastModifiedAt,
  }) {
    return UserPublic(
      userId: userId,
      userType: userType,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      bio: bio ?? this.bio,
      inviteCode: inviteCode ?? this.inviteCode,
      organizationId: organizationId ?? this.organizationId,
      residentialData: residentialData ?? this.residentialData,
      fiscalData: fiscalData ?? this.fiscalData,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }
}
