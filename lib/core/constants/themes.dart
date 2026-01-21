import 'package:flutter/material.dart';
import 'package:thermal_mobile/core/constants/colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // colorScheme: ColorScheme.fromSeed(
    //   seedColor: AppColors.bluePrimary,
    //   onSurface: AppColors.grey_1,
    //   surfaceVariant: Colors.red,
    //   onSurfaceVariant: AppColors.whitePrimary,
    // ),
    // scaffoldBackgroundColor: AppColors.lightBackground,
    // bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    //   selectedItemColor: AppColors.bluePrimary,
    //   unselectedItemColor: AppColors.blackPrimary,
    //   backgroundColor: AppColors.white,
    // ),
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: AppColors.lightBackground,
    //   titleTextStyle: TextStyle(
    //     color: AppColors.blackText,
    //     fontSize: 24,
    //     fontWeight: FontWeight.bold,
    //     fontFamily: "Roboto Serif",
    //   ),
    //   iconTheme: IconThemeData(color: AppColors.text),
    // ),
    // textTheme: const TextTheme(
    //   titleLarge: TextStyle(
    //     color: AppColors.blackText,
    //     fontSize: 20,
    //     fontWeight: FontWeight.bold,
    //   ),
    //   bodyMedium: TextStyle(color: AppColors.blackText, fontSize: 16),
    //   bodyLarge: TextStyle(
    //     color: AppColors.blackText,
    //     fontSize: 20,
    //     fontWeight: FontWeight.bold,
    //   ),
    // ),
    // cardTheme: CardThemeData(color: AppColors.grey_3, 
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16.0),
    //   ),
    //   elevation: 0,
    // ),
  );

  static ThemeData darkTheme = ThemeData(
    // colorScheme: ColorScheme.fromSeed(
    //   seedColor: AppColors.bluePrimary,
    //   onSurface: AppColors.grey_2,
    //   onSurfaceVariant: AppColors.blackPrimary,
    // ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.text,
      backgroundColor: AppColors.menuBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: "Roboto Serif",
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    // textTheme: const TextTheme(
    //   titleLarge: TextStyle(
    //     color: AppColors.whiteText,
    //     fontSize: 20,
    //     fontWeight: FontWeight.bold,
    //   ),
    //   bodyMedium: TextStyle(color: AppColors.whiteText, fontSize: 16),
    //   bodyLarge: TextStyle(
    //     color: AppColors.whiteText,
    //     fontSize: 20,
    //     fontWeight: FontWeight.bold,
    //   ),
    // ),
    // cardTheme: CardThemeData(color: AppColors.black_3, 
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16.0),
    //   ),
    //   elevation: 0,
    // ),
  );
}
