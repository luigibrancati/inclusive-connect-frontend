import 'package:json_annotation/json_annotation.dart';
import 'user_models.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  final UserType userType;

  LoginRequest({
    required this.email,
    required this.password,
    required this.userType,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class Token {
  final String accessToken;
  @JsonKey(defaultValue: 'bearer')
  final String tokenType;
  final UserReference user;
  final String? createdAt;

  Token({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.user,
    this.createdAt,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final Token token;
  // This field can be either MemberPublic or OrganizationPublic. 
  // Custom handling or dynamic might be needed if structure differs too much, 
  // but we can try to parse as dynamic and let the UI decide, OR try to deserialize based on userType in the Token or UserReference.
  // For simplicity keeping as dynamic or Map<String, dynamic> for now, or we can use a wrapper.
  // Actually, let's just store the raw JSON and parse it when needed, or define it as dynamic.
  final dynamic user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
