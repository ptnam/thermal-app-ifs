import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thermal_mobile/core/constants/icons.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2638),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF5A626E), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0088FF).withOpacity(0.20),
            blurRadius: 4,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            context,
            index: 0,
            iconPath: AppIcons.icHome,
            activeIconPath: AppIcons.icHome,
            label: 'Trang chủ',
            selectedColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.selectedItemColor,
            unselectedColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.unselectedItemColor,
          ),
          _buildNavItem(
            context,
            index: 1,
            iconPath: AppIcons.icCamera,
            activeIconPath: AppIcons.icCamera,
            label: 'Camera',
            selectedColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.selectedItemColor,
            unselectedColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.unselectedItemColor,
          ),
          // _buildNavItem(
          //   context,
          //   index: 2,
          //   iconPath: AppIcons.icChart,
          //   activeIconPath: AppIcons.icChart,
          //   label: 'Biểu đồ',
          //   selectedColor: Theme.of(
          //     context,
          //   ).bottomNavigationBarTheme.selectedItemColor,
          //   unselectedColor: Theme.of(
          //     context,
          //   ).bottomNavigationBarTheme.unselectedItemColor,
          // ),
          _buildNavItem(
            context,
            index: 2,
            iconPath: AppIcons.icWarning,
            activeIconPath: AppIcons.icWarning,
            label: 'Sự cố',
            selectedColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.selectedItemColor,
            unselectedColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.unselectedItemColor,
          ),
          _buildNavItem(
            context,
            index: 3,
            iconPath: AppIcons.icReport,
            activeIconPath: AppIcons.icReport,
            label: 'Báo cáo',
            selectedColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.selectedItemColor,
            unselectedColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.unselectedItemColor,
          ),
          // _buildNavItem(
          //   context,
          //   index: 5,
          //   iconPath: AppIcons.icSetting,
          //   activeIconPath: AppIcons.icSetting,
          //   label: 'Cài đặt',
          //   selectedColor: Theme.of(
          //     context,
          //   ).bottomNavigationBarTheme.selectedItemColor,
          //   unselectedColor: Theme.of(
          //     context,
          //   ).bottomNavigationBarTheme.unselectedItemColor,
          // ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String iconPath,
    required String activeIconPath,
    required String label,
    Color? selectedColor,
    Color? unselectedColor,
    Color? selectedBackgroundColor,
    Color? unselectedBackgroundColor,
    BoxBorder? selectedBorder,
    BoxBorder? unselectedBorder,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? (selectedColor ?? Theme.of(context).colorScheme.primary)
        : (unselectedColor ?? Colors.grey);

    final backgroundColor = isSelected
        ? selectedBackgroundColor ?? Colors.transparent
        : unselectedBackgroundColor ?? Colors.transparent;

    final border = isSelected ? selectedBorder : unselectedBorder;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.translucent,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: border,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                isSelected ? activeIconPath : iconPath,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
