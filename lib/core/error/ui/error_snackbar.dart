import 'package:flutter/material.dart';
import 'package:domora/core/theme/app_theme.dart';

/// Extension methods para mostrar SnackBars de error y éxito fácilmente.
/// 
/// Uso:
/// ```dart
/// context.showErrorSnackBar('Algo salió mal');
/// context.showSuccessSnackBar('Operación exitosa');
/// ```
extension ErrorSnackBar on BuildContext {
  /// Muestra un SnackBar de error con estilo consistente
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Cerrar',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(this).hideCurrentSnackBar();
            },
          ),
        ),
      );
  }

  /// Muestra un SnackBar de éxito con estilo consistente
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
