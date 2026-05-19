import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/utils/validators.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/core/widgets/role_selector.dart';
import 'package:domora/features/auth/ui/auth_blocs/signup_bloc.dart';

/// Pantalla de registro (HU1).
///
/// Diseño basado en la referencia de marca: AppBar con flecha y título
/// "Registrarse" centrado, encabezado "Empecemos" + subtítulo, selector de
/// rol, campos con label flotante, checkbox de términos, botón verde.
///
/// Mismos campos que el modelo de datos requiere
/// (email, password, confirm, role);
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
  bool _acceptTerms = false;
  bool _showTermsError = false;

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
    final termsOk = _acceptTerms;

    setState(() {
      _showRoleError = !roleOk;
      _showTermsError = !termsOk;
    });

    if (!formOk || !roleOk || !termsOk) return;

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
      // HU1: tras registro, redirige al onboarding del rol seleccionado.
      context.go(AppConstants.routeOnboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Registrarse'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, size: 22),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<SignupBloc, SignupState>(
          listener: _handleStateChange,
          builder: (context, state) {
            final loading = state is SignupLoadingState;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Encabezado.
                  Text('Empecemos', style: theme.textTheme.displayMedium),
                  const SizedBox(height: 12),
                  Text(
                    'Parece que eres nuevo aquí.\nConfiguremos tu perfil.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Selector de rol — central al modelo de datos.
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
                      padding: const EdgeInsets.only(left: 4, top: 6),
                      child: Text(
                        'Selecciona un rol para continuar',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Campos.
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
                          validator: Validators.password,
                          helperText:
                              'Mínimo 8 caracteres, una letra y un número',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmCtrl,
                          label: 'Confirmar contraseña',
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (v) => Validators.confirmPassword(
                              v, _passwordCtrl.text),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Términos y condiciones.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _acceptTerms,
                            onChanged: loading
                                ? null
                                : (v) => setState(() {
                                      _acceptTerms = v ?? false;
                                      if (_acceptTerms) _showTermsError = false;
                                    }),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(
                                  text: 'Al crear una cuenta, aceptas nuestros '),
                              TextSpan(
                                text: 'Términos y condiciones',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showTermsError)
                    Padding(
                      padding: const EdgeInsets.only(left: 34, top: 4),
                      child: Text(
                        'Debes aceptar los términos para continuar',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

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
                          : const Text('Continuar'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer.
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta? ',
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: loading ? null : () => context.pop(),
                          child: Text(
                            'Iniciar sesión',
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
