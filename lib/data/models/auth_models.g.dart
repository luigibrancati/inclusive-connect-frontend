// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
  userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'userType': _$UserTypeEnumMap[instance.userType]!,
    };

const _$UserTypeEnumMap = {
  UserType.member: 'member',
  UserType.organization: 'organization',
};

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
  accessToken: json['accessToken'] as String,
  tokenType: json['tokenType'] as String? ?? 'bearer',
  user: UserReference.fromJson(Map<String, dynamic>.from(json['user'])),
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'tokenType': instance.tokenType,
  'user': instance.user,
  'createdAt': instance.createdAt,
};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      token: Token.fromJson(Map<String, dynamic>.from(json['token'])),
      user: json['user'],
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{'token': instance.token, 'user': instance.user};
