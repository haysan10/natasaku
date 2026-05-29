import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Compatibility shim — prefer [AppColors] and [AppTheme] from `core/theme`.
@Deprecated('Import core/theme/app_colors.dart and core/theme/app_theme.dart')
class AppTheme {
  AppTheme._();

  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primarySoft = AppColors.primarySoft;
  static const Color primaryContainer = AppColors.primaryContainer;

  static const Color background = AppColors.backgroundLight;
  static const Color backgroundDark = AppColors.backgroundDark;
  static const Color surface = AppColors.surfaceLight;
  static const Color surfaceDark = AppColors.surfaceDark;
  static const Color surfaceVariant = AppColors.surfaceVariantLight;
  static const Color surfaceVariantDark = AppColors.surfaceVariantDark;

  static const Color textPrimary = AppColors.textPrimaryLight;
  static const Color textPrimaryDark = AppColors.textPrimaryDark;
  static const Color textSecondary = AppColors.textSecondaryLight;
  static const Color textSecondaryDark = AppColors.textSecondaryDark;

  static const Color border = AppColors.borderLight;
  static const Color borderDark = AppColors.borderDark;

  static const Color success = AppColors.success;
  static const Color successSoft = AppColors.successSoft;
  static const Color warning = AppColors.warning;
  static const Color warningSoft = AppColors.warningSoft;
  static const Color error = AppColors.error;
  static const Color errorSoft = AppColors.errorSoft;
  static const Color info = AppColors.info;
}
