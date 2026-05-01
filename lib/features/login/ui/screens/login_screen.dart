import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/utils/validators.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/core/widgets/simple_form.dart';
import 'package:domora/features/login/ui/bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

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
      // Redirección según rol y estado de onboarding (HU2).
      if (!state.result.onboardingCompleted) {
        context.go(AppConstants.routeOnboarding);
        return;
      }
      switch (state.result.role) {
        case AppConstants.roleProvider:
          context.go(AppConstants.routeProviderHome);
          break;
        case AppConstants.roleClient:
        default:
          context.go(AppConstants.routeClientHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: _handleStateChange,
          builder: (context, state) {
            final loading = state is LoginLoadingState;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logotipo / insignia
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.cottage_outlined,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 28),
                  Text('Bienvenido de nuevo',
                      style: theme.textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa tus datos para continuar con Domora.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  SimpleForm(
                    formKey: _formKey,
                    children: [
                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'Correo electrónico',
                        hint: 'tucorreo@ejemplo.com',
                        prefixIcon: Icons.alternate_email,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      CustomTextField(
                        controller: _passwordCtrl,
                        label: 'Contraseña',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 8),
                      CustomButton(
                        label: 'Iniciar sesión',
                        onPressed: _submit,
                        isLoading: loading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿No tienes cuenta? ',
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () => context.push(AppConstants.routeSignup),
                        child: const Text('Regístrate'),
                      ),
                    ],
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
