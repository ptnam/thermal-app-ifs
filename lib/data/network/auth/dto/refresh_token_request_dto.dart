class RefreshTokenRequestDto {
  final String accessToken;
  final String refreshToken;

  const RefreshTokenRequestDto({
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}


