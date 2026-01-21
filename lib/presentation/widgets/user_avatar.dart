import 'package:flutter/material.dart';

/// Widget avatar có thể tái sử dụng
/// Hiển thị ảnh avatar hoặc chữ cái đầu tiên của tên nếu không có ảnh
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.radius = 20,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.backgroundColor,
    this.textColor,
  });

  /// Lấy chữ cái đầu tiên của tên và viết hoa
  String _getInitial(String name) {
    if (name.isEmpty) return '?';
    return name.trim()[0].toUpperCase();
  }

  /// Tạo màu nền dựa trên tên để avatar có màu khác nhau
  Color _getBackgroundColor(String name) {
    if (backgroundColor != null) return backgroundColor!;
    
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
    ];
    
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: _getBackgroundColor(name),
        backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
            ? NetworkImage(avatarUrl!)
            : null,
        child: avatarUrl == null || avatarUrl!.isEmpty
            ? Text(
                _getInitial(name),
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
