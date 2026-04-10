/// Application-wide [ThemeData] for the OWON B41T multimeter app.
///
/// Pass [AppTheme.data] to [MaterialApp.theme]. The theme configures every
/// standard Flutter component used in the app so that individual widgets
/// do not need to repeat visual declarations. Custom semantic colors that
/// cannot be expressed through [ThemeData] are available as constants on
/// [AppColors].
///
/// ## What the theme covers
/// - [ColorScheme] — primary (green), secondary (cyan), surface, error
/// - [AppBarTheme] — background, icon colour, title text style
/// - [ElevatedButtonThemeData] — confirm / primary-action style
/// - [OutlinedButtonThemeData] — hardware control-button style
/// - [DialogTheme] — dark background, rounded corners, title text style
/// - [InputDecorationTheme] — filled dark fields, coloured focus border
/// - [TabBarTheme] — green active tab, dim inactive, matching indicator
/// - [DividerThemeData] — standard border colour
/// - [SwitchThemeData] — green-on-dark thumb and track
/// - [TooltipThemeData] — consistent wait duration and dark styling
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get data => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bg0,

        colorScheme: const ColorScheme.dark(
          primary: AppColors.green,
          secondary: AppColors.cyan,
          surface: AppColors.bg2,
          error: AppColors.red,
        ),

        // ------------------------------------------------------------------ //
        // App bar
        // ------------------------------------------------------------------ //
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.bg2,
          iconTheme: IconThemeData(color: AppColors.dim5),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),

        // ------------------------------------------------------------------ //
        // Buttons
        // ------------------------------------------------------------------ //

        /// Confirm / primary actions (rename, connect).
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.greenMid,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        /// Hardware control buttons (HOLD, REL, RANGE, …).
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.cyan,
            backgroundColor: AppColors.cyanDeep,
            side: const BorderSide(color: AppColors.cyanDark, width: 1),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            textStyle: const TextStyle(fontSize: 12, letterSpacing: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // ------------------------------------------------------------------ //
        // Dialogs
        // ------------------------------------------------------------------ //
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.bg3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),

        // ------------------------------------------------------------------ //
        // Text fields
        // ------------------------------------------------------------------ //
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bg0,
          hintStyle: const TextStyle(color: AppColors.dim5),
          counterStyle: const TextStyle(color: AppColors.dim5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.cyan),
          ),
        ),

        // ------------------------------------------------------------------ //
        // Tabs
        // ------------------------------------------------------------------ //
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.green,
          unselectedLabelColor: AppColors.dim5,
          indicatorColor: AppColors.green,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.border,
          labelStyle: TextStyle(
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),

        // ------------------------------------------------------------------ //
        // Dividers
        // ------------------------------------------------------------------ //
        dividerTheme: const DividerThemeData(color: AppColors.border),

        // ------------------------------------------------------------------ //
        // Switch (compatible-only filter toggle in scanner)
        // ------------------------------------------------------------------ //
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.green;
            return AppColors.dim4;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.green.withValues(alpha: 0.45);
            }
            return AppColors.bg5;
          }),
        ),

        // ------------------------------------------------------------------ //
        // Tooltips
        // ------------------------------------------------------------------ //
        tooltipTheme: TooltipThemeData(
          waitDuration: const Duration(milliseconds: 300),
          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: BoxDecoration(
            color: AppColors.bg3,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
        ),
      );
}
