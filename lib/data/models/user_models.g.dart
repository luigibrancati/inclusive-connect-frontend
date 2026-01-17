// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FiscalData _$FiscalDataFromJson(Map<String, dynamic> json) => FiscalData(
  fiscalCode: json['fiscalCode'] as String,
  vatNumber: json['vatNumber'] as String,
  atecoCode: json['atecoCode'] as String?,
);

Map<String, dynamic> _$FiscalDataToJson(FiscalData instance) =>
    <String, dynamic>{
      'fiscalCode': instance.fiscalCode,
      'vatNumber': instance.vatNumber,
      'atecoCode': instance.atecoCode,
    };

UserReference _$UserReferenceFromJson(Map<String, dynamic> json) =>
    UserReference(
      userId: (json['userId'] as num).toInt(),
      userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
    );

Map<String, dynamic> _$UserReferenceToJson(UserReference instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userType': _$UserTypeEnumMap[instance.userType]!,
    };

const _$UserTypeEnumMap = {
  UserType.member: 'member',
  UserType.organization: 'organization',
};

ContentAuthorPublic _$ContentAuthorPublicFromJson(Map<String, dynamic> json) =>
    ContentAuthorPublic(
      userId: (json['userId'] as num).toInt(),
      userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
      username: json['username'] as String,
      profilePicUrl: json['profilePicUrl'] as String?,
    );

Map<String, dynamic> _$ContentAuthorPublicToJson(
  ContentAuthorPublic instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userType': _$UserTypeEnumMap[instance.userType]!,
  'username': instance.username,
  'profilePicUrl': instance.profilePicUrl,
};

UserCreate _$UserCreateFromJson(Map<String, dynamic> json) {
  UserCreate user = UserCreate(
    username: json['username'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
    bio: json['bio'] as String?,
  );
  if (user.userType == UserType.member) {
    user.inviteCode = json['inviteCode'] as String;
    user.organizationId = json['organizationId'] as int;
  } else if (user.userType == UserType.organization) {
    user.residentialData = LocationData.fromJson(
      Map<String, dynamic>.from(json['residentialData']),
    );
    user.fiscalData = FiscalData.fromJson(
      Map<String, dynamic>.from(json['fiscalData']),
    );
  } else {
    throw Exception('Invalid userType value');
  }
  return user;
}

Map<String, dynamic> _$UserCreateToJson(UserCreate user) {
  final json = <String, dynamic>{
    'userType': _$UserTypeEnumMap[user.userType]!,
    'username': user.username,
    'email': user.email,
    'password': user.password,
    'bio': user.bio,
  };
  if (user.userType == UserType.member) {
    json['inviteCode'] = user.inviteCode;
    json['organizationId'] = user.organizationId;
  } else if (user.userType == UserType.organization) {
    json['residentialData'] = user.residentialData!.toJson();
    json['fiscalData'] = user.fiscalData!.toJson();
  }
  return json;
}

UserPublic _$UserPublicFromJson(Map<String, dynamic> json) {
  UserPublic user = UserPublic(
    userId: (json['userId'] as num).toInt(),
    userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
    username: json['username'] as String,
    email: json['email'] as String,
    profilePicUrl: json['profilePicUrl'] as String?,
    bio: json['bio'] as String?,
    createdAt: json['createdAt'] as String,
    lastModifiedAt: json['lastModifiedAt'] as String,
  );
  if (user.userType == UserType.member) {
    user.inviteCode = json['inviteCode'] as String;
    user.organizationId = json['organizationId'] as int;
  } else if (user.userType == UserType.organization) {
    user.residentialData = LocationData.fromJson(
      Map<String, dynamic>.from(json['residentialData']),
    );
    user.fiscalData = FiscalData.fromJson(
      Map<String, dynamic>.from(json['fiscalData']),
    );
  } else {
    throw Exception('Invalid userType value');
  }
  return user;
}

Map<String, dynamic> _$UserPublicToJson(UserPublic user) {
  final json = <String, dynamic>{
    'userId': user.userId,
    'userType': _$UserTypeEnumMap[user.userType]!,
    'username': user.username,
    'email': user.email,
    'profilePicUrl': user.profilePicUrl,
    'bio': user.bio,
    'createdAt': user.createdAt,
    'lastModifiedAt': user.lastModifiedAt,
  };
  if (user.userType == UserType.member) {
    json['inviteCode'] = user.inviteCode;
    json['organizationId'] = user.organizationId;
  } else if (user.userType == UserType.organization) {
    json['residentialData'] = user.residentialData!.toJson();
    json['fiscalData'] = user.fiscalData!.toJson();
  }
  return json;
}
