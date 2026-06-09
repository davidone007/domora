import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/validators.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/features/auth/ui/auth_blocs/forgot_password_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context
        .read<ForgotPasswordBloc>()
        .add(ForgotPasswordSubmitEvent(_emailCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recuperar contraseña'),
      ),
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state.status == ForgotPasswordStatus.success) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Te enviamos un correo con instrucciones para restablecer tu contraseña.',
                  ),
                  backgroundColor: AppTheme.primary,
                ),
              );
              context.pop();
            }
            if (state.status == ForgotPasswordStatus.error &&
                state.errorMessage != null) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppTheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final loading = state.status == ForgotPasswordStatus.submitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¿Olvidaste tu contraseña?',
                      style: theme.textTheme.displayMedium),
                  const SizedBox(height: 12),
                  Text(
                    'Ingresa el correo asociado a tu cuenta y te enviaremos un enlace para restablecerla.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: CustomTextField(
                      controller: _emailCtrl,
                      label: 'Correo electrónico',
                      hint: 'tucorreo@ejemplo.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                  ),
                  const SizedBox(height: 28),
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
                          : const Text('Enviar enlace'),
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
