import 'package:flutter/material.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/error/failures.dart';

/// Dialog para errores moderados.
/// 
/// Se usa para errores que requieren reconocimiento del usuario pero
/// no bloquean completamente el flujo:
/// - Errores de servidor
/// - Errores de autenticación (excepto sesión expirada)
/// - Permisos denegados permanentemente
class ErrorDialog extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    required this.failure,
    this.onRetry,
  });

  /// Muestra el dialog de error
  static Future<void> show(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
        failure: failure,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_outline,
          size: 32,
          color: AppTheme.error,
        ),
      ),
      title: Text(
        _getTitle(),
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: Text(
        failure.message,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actions: onRetry != null ? _buildRetryActions(context) : _buildOkAction(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
    );
  }

  String _getTitle() {
    if (failure is ServerFailure) {
      return 'Error del servidor';
    }
    if (failure is AuthFailure) {
      return 'Error de autenticación';
    }
    if (failure is PermissionFailure) {
      return 'Permiso requerido';
    }
    return 'Error';
  }

  List<Widget> _buildOkAction(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Entendido'),
      ),
    ];
  }

  List<Widget> _buildRetryActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          onRetry?.call();
        },
        child: const Text('Reintentar'),
      ),
    ];
  }
}
