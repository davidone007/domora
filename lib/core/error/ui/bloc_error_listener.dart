import 'package:domora/core/error/failures.dart';
import 'package:domora/core/error/ui/error_ui_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget que escucha estados de error en BLoCs y muestra UI automáticamente.
/// 
/// Simplifica el manejo de errores eliminando código repetitivo en cada pantalla.
/// 
/// Uso:
/// ```dart
/// BlocErrorListener<LoginBloc, LoginState>(
///   failureSelector: (state) {
///     if (state is LoginFailState) {
///       return AuthFailure(state.message);
///     }
///     return null;
///   },
///   retrySelector: (state) {
///     if (state is LoginFailState) {
///       return () => context.read<LoginBloc>().add(LoginRetryEvent());
///     }
///     return null;
///   },
///   child: LoginForm(),
/// )
/// ```
class BlocErrorListener<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  /// Widget hijo que se mostrará
  final Widget child;

  /// Función que extrae un Failure del estado, o null si no hay error
  final Failure? Function(S state) failureSelector;

  /// Función que retorna un callback de retry, o null si no aplica
  final VoidCallback? Function(S state)? retrySelector;

  /// Factory para crear widgets de error (opcional, usa default si no se provee)
  final ErrorUIFactory? errorUIFactory;

  const BlocErrorListener({
    super.key,
    required this.child,
    required this.failureSelector,
    this.retrySelector,
    this.errorUIFactory,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listener: (context, state) {
        final failure = failureSelector(state);
        if (failure != null) {
          final retry = retrySelector?.call(state);
          final factory = errorUIFactory ?? const ErrorUIFactory();
          factory.showError(
            context,
            failure,
            onRetry: retry,
          );
        }
      },
      child: child,
    );
  }
}
