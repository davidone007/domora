import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/utils/validators.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/features/login/ui/bloc/login_bloc.dart';

/// Pantalla de inicio de sesión (HU2).
///
/// Diseño basado en la referencia de marca: header con flecha de regreso,
/// título grande, subtítulo gris, dos campos con label flotante, fila de
/// "Recuérdame" + "¿Olvidaste tu contraseña?", botón verde, link al registro.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  /// "Recuérdame" — actualmente decorativo: Supabase ya persiste la sesión
  /// por defecto, así que el toggle existe sólo por consistencia con el
  /// diseño. Si en el futuro se desactiva la persistencia automática, este
  /// es el flag que decidiría si guardarla manualmente.
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginBloc>().add(
          LoginSubmitEvent(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
          ),
        );
  }

  void _handleStateChange(BuildContext context, LoginState state) {
    if (state is LoginFailState) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    } else if (state is LoginSuccessState) {
      // HU2: redirección según rol y estado de onboarding.
      if (!state.onboardingCompleted) {
        context.go(AppConstants.routeOnboarding);
        return;
      }
      switch (state.role) {
        case AppConstants.roleProvider:
          context.go(AppConstants.routeProviderHome);
          break;
        case AppConstants.roleClient:
        default:
          context.go(AppConstants.routeClientHome);
      }
    }
  }

  void _onForgotPassword() {
    // HU posterior: pantalla de recuperación. Por ahora informamos.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Recuperación disponible próximamente')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: _handleStateChange,
          builder: (context, state) {
            final loading = state is LoginLoadingState;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón regresar.
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppConstants.routeWelcome);
                      }
                    },
                    icon: const Icon(Icons.arrow_back, size: 22),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    visualDensity: VisualDensity.compact,
                  ),

                  const SizedBox(height: 48),

                  // Título.
                  Text('Iniciemos Sesión', style: theme.textTheme.displayMedium),
                  const SizedBox(height: 12),
                  Text(
                    '¡Bienvenido de nuevo! Te extrañamos.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Formulario.
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailCtrl,
                          label: 'Correo electrónico',
                          hint: 'tucorreo@ejemplo.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordCtrl,
                          label: 'Contraseña',
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (v) =>
                              Validators.required(v, fieldName: 'La contraseña'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recuérdame + ¿Olvidaste tu contraseña?
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: loading
                              ? null
                              : (v) => setState(
                                  () => _rememberMe = v ?? false),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recuérdame',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: loading ? null : _onForgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Botón principal.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Inicia sesión'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer: ¿No tienes una cuenta? Regístrate
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes una cuenta? ',
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: loading
                              ? null
                              : () => context.push(AppConstants.routeSignup),
                          child: Text(
                            'Regístrate',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
