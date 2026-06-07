import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/features/auth/ui/auth_blocs/reset_password_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context
        .read<ResetPasswordBloc>()
        .add(ResetPasswordSubmitEvent(_passwordCtrl.text));
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != _passwordCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeLogin),
        ),
        title: const Text('Nueva contraseña'),
      ),
      body: SafeArea(
        child: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
          listener: (context, state) {
            if (state.status == ResetPasswordStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña actualizada correctamente'),
                  backgroundColor: AppTheme.primary,
                ),
              );
              context.go(AppConstants.routeSplash);
            }
            if (state.status == ResetPasswordStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppTheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final loading = state.status == ResetPasswordStatus.loading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crea tu nueva contraseña',
                      style: theme.textTheme.displayMedium),
                  const SizedBox(height: 12),
                  Text(
                    'Elige una contraseña segura de al menos 8 caracteres.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _passwordCtrl,
                          label: 'Nueva contraseña',
                          hint: '••••••••',
                          isPassword: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmCtrl,
                          label: 'Confirmar contraseña',
                          hint: '••••••••',
                          isPassword: true,
                          validator: _validateConfirm,
                        ),
                      ],
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
                          : const Text('Guardar contraseña'),
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
