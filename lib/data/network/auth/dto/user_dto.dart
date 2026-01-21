class UserDto {
  final String id;
  final String username;
  final String? fullName;
  final String? email;

  const UserDto({
    required this.id,
    required this.username,
    this.fullName,
    this.email,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'fullName': fullName,
    'email': email,
  };
}


