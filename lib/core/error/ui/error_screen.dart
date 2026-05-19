import 'package:flutter/material.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/error/failures.dart';

/// Pantalla completa para errores críticos con opción de retry.
/// 
/// Se usa para errores que requieren atención inmediata del usuario:
/// - Errores de red (sin conexión, timeout)
/// - Sesión expirada
/// - Otros errores críticos que bloquean el flujo
class ErrorScreen extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;
  final VoidCallback? onBack;

  const ErrorScreen({
    super.key,
    required this.failure,
    required this.onRetry,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Icono de error
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.error,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Título
              Text(
                _getTitle(),
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Mensaje descriptivo
              Text(
                failure.message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Botón Reintentar (primario)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  child: const Text('Reintentar'),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Botón Volver (secundario)
              if (onBack != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onBack?.call();
                  },
                  child: const Text('Volver'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    if (failure is NetworkFailure) {
      return 'Sin conexión';
    }
    if (failure is AuthFailure) {
      return 'Sesión expirada';
    }
    return 'Algo salió mal';
  }
}
