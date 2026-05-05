import 'package:domora/features/onboarding/domain/entities/avatar_file.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/utils/colombia_locations.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/utils/validators.dart';
import 'package:domora/core/widgets/avatar_picker.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/core/widgets/loading_overlay.dart';
import 'package:domora/core/widgets/phone_field.dart';
import 'package:domora/core/widgets/simple_form.dart';
import 'package:domora/features/onboarding/ui/bloc/onboarding_bloc.dart';

/// Pantalla de onboarding inicial.
///
/// Recibe el [role] y [userId] resueltos previamente desde la sesión
/// del usuario (via _OnboardingRouteResolver en el router).
class OnboardingScreen extends StatefulWidget {
  final String role;
  final String userId;

  const OnboardingScreen({super.key, required this.role, required this.userId});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Comunes
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _dialCode = '+57';
  AvatarFile? _avatar;

  // Solo proveedor
  final _yearsCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _addressLine1Ctrl = TextEditingController();
  final _addressLine2Ctrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  String? _selectedDepartment;
  String? _selectedCity;

  bool get _isProvider => widget.role == AppConstants.roleProvider;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _yearsCtrl.dispose();
    _rateCtrl.dispose();
    _bioCtrl.dispose();
    _addressLine1Ctrl.dispose();
    _addressLine2Ctrl.dispose();
    _neighborhoodCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isProvider) {
      final years = int.tryParse(_yearsCtrl.text.trim()) ?? 0;
      final rate =
          double.tryParse(_rateCtrl.text.trim().replaceAll(',', '.')) ?? 0;

      context.read<OnboardingBloc>().add(
            OnboardingSaveProviderEvent(
              userId: widget.userId,
              firstName: _firstNameCtrl.text.trim(),
              lastName: _lastNameCtrl.text.trim(),
              phone: '$_dialCode ${_phoneCtrl.text.trim()}',
              yearsExperience: years,
              hourlyRate: rate,
              bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
              avatar: _avatar,
              addressLine1: _addressLine1Ctrl.text.trim(),
              addressLine2:
                  _addressLine2Ctrl.text.trim().isEmpty
                      ? null
                      : _addressLine2Ctrl.text.trim(),
              department: _selectedDepartment ?? '',
              city: _selectedCity ?? '',
              neighborhood:
                  _neighborhoodCtrl.text.trim().isEmpty
                      ? null
                      : _neighborhoodCtrl.text.trim(),
            ),
          );
    } else {
      context.read<OnboardingBloc>().add(
            OnboardingSaveClientEvent(
              userId: widget.userId,
              firstName: _firstNameCtrl.text.trim(),
              lastName: _lastNameCtrl.text.trim(),
              phone: '$_dialCode ${_phoneCtrl.text.trim()}',
              avatar: _avatar,
            ),
          );
    }
  }

  void _handleStateChange(BuildContext context, OnboardingState state) {
    if (state is OnboardingFailState) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    } else if (state is OnboardingSuccessState) {
      // Redirige al dashboard según rol.
      context.go(state.role == AppConstants.roleProvider
          ? AppConstants.routeProviderHome
          : AppConstants.routeClientHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: _handleStateChange,
          builder: (context, state) {
            final loading = state is OnboardingLoadingState;

            return LoadingOverlay(
              isLoading: loading,
              message: 'Guardando tu perfil...',
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isProvider ? 'Cuéntanos sobre ti' : 'Completa tu perfil',
                      style: theme.textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isProvider
                          ? 'Esta información ayuda a los clientes a conocerte y elegir tus servicios.'
                          : 'Necesitamos algunos datos para personalizar tu experiencia.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    AvatarPicker(
                      image: _avatar,
                      onChanged: (f) => setState(() => _avatar = f),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _isProvider
                            ? 'Foto de perfil (recomendada)'
                            : 'Foto de perfil (opcional)',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SimpleForm(
                      formKey: _formKey,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _firstNameCtrl,
                                label: 'Nombres',
                                prefixIcon: Icons.badge_outlined,
                                validator: (v) =>
                                    Validators.name(v, label: 'nombre'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _lastNameCtrl,
                                label: 'Apellidos',
                                validator: (v) =>
                                    Validators.name(v, label: 'apellido'),
                              ),
                            ),
                          ],
                        ),
                        PhoneField(
                          controller: _phoneCtrl,
                          dialCode: _dialCode,
                          onDialCodeChanged: (code) =>
                              setState(() => _dialCode = code),
                          validator: Validators.phoneNumber,
                        ),

                        //  SOLO PROVEEDOR 
                        if (_isProvider) ...[
                          const _SectionHeader(
                            title: 'Sobre tu experiencia',
                            icon: Icons.work_outline,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _yearsCtrl,
                                  label: 'Años de experiencia',
                                  prefixIcon: Icons.timeline_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: Validators.yearsExperience,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _rateCtrl,
                                  label: 'Tarifa por hora',
                                  hint: 'COP',
                                  prefixIcon: Icons.attach_money,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: Validators.hourlyRate,
                                ),
                              ),
                            ],
                          ),
                          CustomTextField(
                            controller: _bioCtrl,
                            label: 'Biografía',
                            hint:
                                'Cuenta brevemente sobre tu trabajo y especialidad',
                            maxLines: 4,
                            maxLength: 500,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            validator: (v) => Validators.bio(v, max: 500),
                          ),
                          const _SectionHeader(
                            title: 'Tu ubicación de trabajo',
                            icon: Icons.location_on_outlined,
                          ),
                          CustomTextField(
                            controller: _addressLine1Ctrl,
                            label: 'Dirección',
                            hint: 'Calle 10 # 20-30',
                            prefixIcon: Icons.home_outlined,
                            validator: (v) =>
                                Validators.required(v, fieldName: 'La dirección'),
                          ),
                          CustomTextField(
                            controller: _addressLine2Ctrl,
                            label: 'Apartamento / referencia (opcional)',
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedDepartment,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Departamento',
                              prefixIcon: Icon(Icons.map_outlined, size: 20),
                            ),
                            items: ColombiaLocations.departmentList
                                .map(
                                  (department) => DropdownMenuItem(
                                    value: department,
                                    child: Text(department),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDepartment = value;
                                _selectedCity = null;
                              });
                            },
                            validator: (v) =>
                                Validators.required(v, fieldName: 'El departamento'),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCity,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Ciudad',
                                    prefixIcon: Icon(
                                      Icons.location_city_outlined,
                                      size: 20,
                                    ),
                                  ),
                                  items: (_selectedDepartment == null)
                                      ? const []
                                      : ColombiaLocations.citiesFor(
                                          _selectedDepartment!,
                                        )
                                          .map(
                                            (city) => DropdownMenuItem(
                                              value: city,
                                              child: Text(city),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: _selectedDepartment == null
                                      ? null
                                      : (value) =>
                                          setState(() => _selectedCity = value),
                                  validator: (v) =>
                                      Validators.required(v, fieldName: 'La ciudad'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _neighborhoodCtrl,
                                  label: 'Barrio (opcional)',
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Continuar',
                          icon: Icons.arrow_forward,
                          onPressed: _submit,
                          isLoading: loading,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}
