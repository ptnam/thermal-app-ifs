import 'auth_tokens_dto.dart';
import 'user_dto.dart';

class LoginResponseDto {
  final UserDto user;
  final AuthTokensDto tokens;

  const LoginResponseDto({required this.user, required this.tokens});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokensDto.fromJson(json),
    );
  }
}


