import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/utils/validators.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/core/widgets/role_selector.dart';
import 'package:domora/core/widgets/simple_form.dart';
import 'package:domora/features/signup/ui/bloc/signup_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _role;
  bool _showRoleError = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final formOk = _formKey.currentState?.validate() ?? false;
    final roleOk = _role != null;
    setState(() => _showRoleError = !roleOk);
    if (!formOk || !roleOk) return;

    context.read<SignupBloc>().add(
          SignupSubmitEvent(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            role: _role!,
          ),
        );
  }

  void _handleStateChange(BuildContext context, SignupState state) {
    if (state is SignupFailState) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    } else if (state is SignupSuccessState) {
      // HU1: tras registro, redirige a onboarding del rol seleccionado.
      context.go(AppConstants.routeOnboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<SignupBloc, SignupState>(
          listener: _handleStateChange,
          builder: (context, state) {
            final loading = state is SignupLoadingState;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crea tu cuenta',
                      style: theme.textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Únete a Domora y conecta con la red de servicios para el hogar.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  SimpleForm(
                    formKey: _formKey,
                    children: [
                      RoleSelector(
                        selected: _role,
                        onChanged: (r) {
                          setState(() {
                            _role = r;
                            _showRoleError = false;
                          });
                        },
                      ),
                      if (_showRoleError)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Text(
                            'Selecciona un rol para continuar',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
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
                        validator: Validators.password,
                        helperText: 'Mínimo 8 caracteres, una letra y un número',
                      ),
                      CustomTextField(
                        controller: _confirmCtrl,
                        label: 'Confirmar contraseña',
                        prefixIcon: Icons.lock_reset_outlined,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) =>
                            Validators.confirmPassword(v, _passwordCtrl.text),
                      ),
                      const SizedBox(height: 8),
                      CustomButton(
                        label: 'Crear cuenta',
                        onPressed: _submit,
                        isLoading: loading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿Ya tienes cuenta? ',
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: loading ? null : () => context.pop(),
                        child: const Text('Inicia sesión'),
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
