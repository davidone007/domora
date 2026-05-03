import 'package:flutter/material.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/core/error/ui/error_dialog.dart';
import 'package:domora/core/error/ui/error_screen.dart';

/// Tipos de UI para mostrar errores
enum ErrorUIType {
  /// SnackBar para errores leves (validación, campos vacíos)
  snackBar,

  /// Dialog para errores moderados (fallo de operación)
  dialog,

  /// Pantalla completa para errores críticos (sin conexión, sesión expirada)
  fullScreen,
}

/// Factory para crear y mostrar widgets de error apropiados según el tipo de Failure.
/// 
/// Determina automáticamente el tipo de UI más apropiado basándose en la
/// severidad del error y proporciona métodos para mostrar cada tipo de UI.
class ErrorUIFactory {
  const ErrorUIFactory();

  /// Determina el tipo de UI apropiado para un Failure
  ErrorUIType getUIType(Failure failure) {
    // Errores críticos → pantalla completa
    if (failure is NetworkFailure) {
      return ErrorUIType.fullScreen;
    }

    if (failure is AuthFailure) {
      // Sesión expirada es crítico
      if (failure.message.contains('expirado') ||
          failure.message.contains('expired')) {
        return ErrorUIType.fullScreen;
      }
      // Otros errores de auth son moderados
      return ErrorUIType.dialog;
    }

    // Errores de servidor son moderados
    if (failure is ServerFailure) {
      return ErrorUIType.dialog;
    }

    // Permisos denegados permanentemente son moderados
    if (failure is PermissionFailure && failure.permanentlyDenied) {
      return ErrorUIType.dialog;
    }

    // Validación y otros son leves
    return ErrorUIType.snackBar;
  }

  /// Muestra el error usando el widget apropiado
  void showError(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    try {
      final uiType = getUIType(failure);

      switch (uiType) {
        case ErrorUIType.snackBar:
          showSnackBar(context, failure.message);
          break;

        case ErrorUIType.dialog:
          showDialog(context, failure, onRetry: onRetry);
          break;

        case ErrorUIType.fullScreen:
          if (onRetry != null) {
            showErrorScreen(context, failure, onRetry: onRetry);
          } else {
            // Si no hay retry, usar dialog
            showDialog(context, failure);
          }
          break;
      }
    } catch (e) {
      // Fallback a SnackBar simple si algo falla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }
  }

  /// Muestra SnackBar para errores leves
  void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Cerrar',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
  }

  /// Muestra Dialog para errores moderados
  Future<void> showDialog(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    return ErrorDialog.show(context, failure, onRetry: onRetry);
  }

  /// Navega a pantalla completa para errores críticos
  Future<void> showErrorScreen(
    BuildContext context,
    Failure failure, {
    required VoidCallback onRetry,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PopScope(
          canPop: false,
          child: ErrorScreen(
            failure: failure,
            onRetry: onRetry,
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
