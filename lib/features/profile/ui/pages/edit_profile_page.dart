import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import 'package:domora/core/error/ui/error_snackbar.dart';
import 'package:domora/core/utils/colombia_locations.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/utils/validators.dart';
import 'package:domora/core/widgets/avatar_picker.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/core/widgets/loading_overlay.dart';
import 'package:domora/core/widgets/simple_form.dart';
import 'package:domora/core/entities/avatar_file.dart';
import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/ui/bloc/profile_edit_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final FullProfile? initialProfile;

  const EditProfilePage({super.key, this.initialProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _personalFormKey = GlobalKey<FormState>();
  final _providerFormKey = GlobalKey<FormState>();
  final _clientFormKey = GlobalKey<FormState>();
  final _locationFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Basic user fields
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Email update fields
  final _currentPasswordForEmailCtrl = TextEditingController();
  final _newEmailCtrl = TextEditingController();

  // Password update fields
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // Client-specific fields
  final _clientBioCtrl = TextEditingController();

  // Provider-specific fields
  final _providerBioCtrl = TextEditingController();
  final _yearsExperienceCtrl = TextEditingController();
  final _hourlyRateCtrl = TextEditingController();
  final _addressLine1Ctrl = TextEditingController();
  final _addressLine2Ctrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  String? _selectedDepartment;
  String? _selectedCity;
  bool _providerIsAvailable = true;

  // UI state
  bool _showEmailEditor = false;
  bool _showPasswordEditor = false;
  AvatarFile? _selectedAvatar;
  String? _currentAvatarUrl;
  DateTime? _lastAvatarSuccessAt;

  late final String _userId;
  late final bool _isProvider;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    if (profile != null) {
      _userId = profile.user.id;
      _isProvider = profile.role == AppConstants.roleProvider;

      _firstNameCtrl.text = profile.user.firstName ?? '';
      _lastNameCtrl.text = profile.user.lastName ?? '';
      _phoneCtrl.text = profile.user.phone ?? '';
      _emailCtrl.text = profile.user.email;

      if (_isProvider && profile.providerProfile != null) {
        _providerBioCtrl.text = profile.providerProfile?.bio ?? '';
        _yearsExperienceCtrl.text = (profile.providerProfile?.yearsExperience ?? 0).toString();
        _hourlyRateCtrl.text = (profile.providerProfile?.hourlyRate ?? 0).toString();
        _providerIsAvailable = profile.providerProfile?.isAvailable ?? true;
        _currentAvatarUrl = profile.providerProfile?.avatarUrl;
        final address = profile.primaryAddress;
        if (address != null) {
          _addressLine1Ctrl.text = address.addressLine1;
          _addressLine2Ctrl.text = address.addressLine2 ?? '';
          _neighborhoodCtrl.text = address.neighborhood ?? '';
          _selectedDepartment = address.department.isNotEmpty ? address.department : null;
          _selectedCity = address.city.isNotEmpty ? address.city : null;
        }
      } else if (!_isProvider && profile.clientProfile != null) {
        _clientBioCtrl.text = profile.clientProfile?.bio ?? '';
        _currentAvatarUrl = profile.clientProfile?.avatarUrl;
      }
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _currentPasswordForEmailCtrl.dispose();
    _newEmailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _clientBioCtrl.dispose();
    _providerBioCtrl.dispose();
    _yearsExperienceCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _addressLine1Ctrl.dispose();
    _addressLine2Ctrl.dispose();
    _neighborhoodCtrl.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, ProfileEditState state) {
    if (state is ProfileEditFailure) {
      // If an avatar upload just succeeded, ignore immediately-following failures
      final now = DateTime.now();
      if (_lastAvatarSuccessAt != null && now.difference(_lastAvatarSuccessAt!).inSeconds < 3) {
        if (context.mounted) context.read<ProfileEditBloc>().add(const ProfileEditResetEvent());
        return;
      }

      context.showErrorSnackBar(state.message);
      // Reset state after showing error
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (context.mounted) context.read<ProfileEditBloc>().add(const ProfileEditResetEvent());
      });
      return;
    }

    if (state is AvatarUploadSuccess) {
      // Update UI to show the new avatar URL returned by the use case
      _currentAvatarUrl = state.avatarUrl;
      setState(() => _selectedAvatar = null);
      _lastAvatarSuccessAt = DateTime.now();
      context.showSuccessSnackBar('Foto de perfil actualizada');
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (context.mounted) context.read<ProfileEditBloc>().add(const ProfileEditResetEvent());
      });
      return;
    }

    if (state is ProfileEditSuccess) {
      // Handle specific success messages to update UI accordingly
      final isCredentialsUpdate =
          state.message.toLowerCase().contains('correo') ||
          state.message.toLowerCase().contains('contraseña');

      if (state.message.toLowerCase().contains('correo')) {
        setState(() {
          _emailCtrl.text = _newEmailCtrl.text.trim().toLowerCase();
          _newEmailCtrl.clear();
          _currentPasswordForEmailCtrl.clear();
          _showEmailEditor = false;
        });
      }

      if (state.message.toLowerCase().contains('contraseña')) {
        setState(() {
          _newPasswordCtrl.clear();
          _confirmPasswordCtrl.clear();
          _currentPasswordCtrl.clear();
          _showPasswordEditor = false;
        });
      }

      context.showSuccessSnackBar(state.message);

      if (isCredentialsUpdate) {
        // Credentials updates stay on the page; only reset BLoC state.
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) context.read<ProfileEditBloc>().add(const ProfileEditResetEvent());
        });
      } else {
        // Field updates (personal info, provider info, location): pop back so
        // ProfilePage reloads the data via its await-push + ProfileRefreshEvent.
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) context.pop();
        });
      }
    }
  }

  void _submitProfileUpdate() {
    if (!_personalFormKey.currentState!.validate()) return;
    context.read<ProfileEditBloc>().add(
          UpdateProfileFieldsEvent(
            userId: _userId,
            firstName: _firstNameCtrl.text.isNotEmpty ? _firstNameCtrl.text : null,
            lastName: _lastNameCtrl.text.isNotEmpty ? _lastNameCtrl.text : null,
            phone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
          ),
        );
  }

  void _submitClientProfileUpdate() {
    if (!_clientFormKey.currentState!.validate()) return;
    context.read<ProfileEditBloc>().add(
          UpdateClientProfileEvent(
            userId: _userId,
            bio: _clientBioCtrl.text.isNotEmpty ? _clientBioCtrl.text : null,
          ),
        );
  }

  void _submitProviderProfileUpdate() {
    if (!_providerFormKey.currentState!.validate()) return;
    final yearsExp = int.tryParse(_yearsExperienceCtrl.text) ?? 0;
    final hourlyRate = double.tryParse(_hourlyRateCtrl.text) ?? 0;

    context.read<ProfileEditBloc>().add(
          UpdateProviderProfileEvent(
            userId: _userId,
            yearsExperience: yearsExp > 0 ? yearsExp : null,
            hourlyRate: hourlyRate > 0 ? hourlyRate : null,
            isAvailable: _providerIsAvailable,
            bio: _providerBioCtrl.text.isNotEmpty ? _providerBioCtrl.text : null,
          ),
        );
  }

  void _submitProviderLocationUpdate() {
    if (!_locationFormKey.currentState!.validate()) return;

    if (_selectedDepartment == null || _selectedCity == null) {
      return;
    }

    context.read<ProfileEditBloc>().add(
          UpdateProviderAddressEvent(
            userId: _userId,
            addressLine1: _addressLine1Ctrl.text.trim(),
            addressLine2: _addressLine2Ctrl.text.trim().isEmpty
                ? null
                : _addressLine2Ctrl.text.trim(),
            department: _selectedDepartment!,
            city: _selectedCity!,
            neighborhood: _neighborhoodCtrl.text.trim().isEmpty
                ? null
                : _neighborhoodCtrl.text.trim(),
          ),
        );
  }

  void _submitEmailUpdate() {
    if (!_emailFormKey.currentState!.validate()) return;
    context.read<ProfileEditBloc>().add(
          UpdateEmailEvent(
            currentEmail: _emailCtrl.text,
            currentPassword: _currentPasswordForEmailCtrl.text,
            newEmail: _newEmailCtrl.text,
          ),
        );
  }

  void _submitPasswordUpdate() {
    if (!_passwordFormKey.currentState!.validate()) return;
    context.read<ProfileEditBloc>().add(
          UpdatePasswordEvent(
            currentPassword: _currentPasswordCtrl.text,
            newPassword: _newPasswordCtrl.text,
            confirmPassword: _confirmPasswordCtrl.text,
          ),
        );
  }

  void _handleAvatarSelected(AvatarFile? avatar) {
    if (avatar == null) {
      // User chose to remove avatar: update DB to clear avatar_url
      setState(() {
        _selectedAvatar = null;
        _currentAvatarUrl = '';
      });

      if (_isProvider) {
        context.read<ProfileEditBloc>().add(
              UpdateProviderProfileEvent(userId: _userId, avatarUrl: ''),
            );
      } else {
        context.read<ProfileEditBloc>().add(
              UpdateClientProfileEvent(userId: _userId, avatarUrl: ''),
            );
      }

      context.showSuccessSnackBar('Foto de perfil removida');
      return;
    }

    setState(() => _selectedAvatar = avatar);
    context.read<ProfileEditBloc>().add(
          UploadAvatarEvent(
            userId: _userId,
            avatarFile: avatar,
            isProvider: _isProvider,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<ProfileEditBloc, ProfileEditState>(
        listener: _handleStateChange,
        builder: (context, state) {
          final loading = state is ProfileEditLoading;

          return LoadingOverlay(
            isLoading: loading,
            message: 'Guardando cambios...',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Editar Perfil',
                          style: theme.textTheme.displayMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppConstants.routeProfile);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Avatar Picker
                    Center(
                      child: Column(
                        children: [
                          AvatarPicker(
                            image: _selectedAvatar,
                            imageUrl: _currentAvatarUrl ?? (_isProvider
                                ? widget.initialProfile?.providerProfile?.avatarUrl
                                : widget.initialProfile?.clientProfile?.avatarUrl),
                            onChanged: _handleAvatarSelected,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Foto de perfil',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Información Personal
                    Text(
                      'Información Personal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SimpleForm(
                      formKey: _personalFormKey,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _firstNameCtrl,
                                label: 'Nombre',
                                prefixIcon: Icons.badge_outlined,
                                validator: Validators.validateNotEmpty,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _lastNameCtrl,
                                label: 'Apellido',
                                validator: Validators.validateNotEmpty,
                              ),
                            ),
                          ],
                        ),
                        CustomTextField(
                          controller: _phoneCtrl,
                          label: 'Teléfono',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: Validators.validatePhone,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          label: 'Guardar Información Personal',
                          onPressed: _submitProfileUpdate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Información Profesional o Adicional
                    if (_isProvider) ...[
                      Text(
                        'Información Profesional',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SimpleForm(
                        formKey: _providerFormKey,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _yearsExperienceCtrl,
                                  label: 'Años de Experiencia',
                                  prefixIcon: Icons.school_outlined,
                                  keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    validator: Validators.yearsExperience,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _hourlyRateCtrl,
                                  label: 'Tarifa/Hora',
                                  prefixIcon: Icons.attach_money_outlined,
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  validator: (v) =>
                                      Validators.validateNumberField(v, 'Tarifa'),
                                ),
                              ),
                            ],
                          ),
                          CheckboxListTile(
                            title: const Text('Disponible para trabajos'),
                            value: _providerIsAvailable,
                            onChanged: (value) =>
                                setState(() => _providerIsAvailable = value ?? true),
                            contentPadding: EdgeInsets.zero,
                          ),
                          CustomTextField(
                            controller: _providerBioCtrl,
                            label: 'Biografía Profesional',
                            prefixIcon: Icons.description_outlined,
                            maxLines: 4,
                            validator: (v) => null,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: 'Guardar Información Profesional',
                            onPressed: _submitProviderProfileUpdate,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ubicación de Trabajo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SimpleForm(
                        formKey: _locationFormKey,
                        children: [
                          CustomTextField(
                            controller: _addressLine1Ctrl,
                            label: 'Dirección',
                            prefixIcon: Icons.home_outlined,
                            validator: (v) => Validators.validateNotEmpty(
                              v,
                              fieldName: 'La dirección',
                            ),
                          ),
                          CustomTextField(
                            controller: _addressLine2Ctrl,
                            label: 'Apartamento / referencia (opcional)',
                            prefixIcon: Icons.apartment_outlined,
                            validator: (v) => Validators.bio(v, max: 120),
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
                            validator: (v) => Validators.validateNotEmpty(
                              v,
                              fieldName: 'El departamento',
                            ),
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
                                      : (value) => setState(() => _selectedCity = value),
                                  validator: (v) => Validators.validateNotEmpty(
                                    v,
                                    fieldName: 'La ciudad',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _neighborhoodCtrl,
                                  label: 'Barrio (opcional)',
                                  prefixIcon: Icons.location_on_outlined,
                                  validator: (v) => Validators.bio(v, max: 80),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: 'Guardar Ubicación',
                            onPressed: _submitProviderLocationUpdate,
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'Información Adicional',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SimpleForm(
                        formKey: _clientFormKey,
                        children: [
                          CustomTextField(
                            controller: _clientBioCtrl,
                            label: 'Biografía',
                            prefixIcon: Icons.description_outlined,
                            maxLines: 4,
                            validator: (v) => null,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: 'Guardar Información',
                            onPressed: _submitClientProfileUpdate,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Seguridad
                    Text(
                      'Seguridad',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cambiar email
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        title: const Text('Cambiar Correo Electrónico'),
                        subtitle: Text(_emailCtrl.text),
                        trailing: Icon(
                          _showEmailEditor
                              ? Icons.expand_less_outlined
                              : Icons.expand_more_outlined,
                        ),
                        onTap: () => setState(() => _showEmailEditor = !_showEmailEditor),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    if (_showEmailEditor) ...[
                      const SizedBox(height: 16),
                      SimpleForm(
                        formKey: _emailFormKey,
                        children: [
                          CustomTextField(
                            controller: _newEmailCtrl,
                            label: 'Nuevo Correo',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => Validators.differentEmail(v, _emailCtrl.text),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {}),
                          ),
                          CustomTextField(
                            controller: _currentPasswordForEmailCtrl,
                            label: 'Contraseña Actual',
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            validator: Validators.validateNotEmpty,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _showEmailEditor = false),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  label: 'Actualizar Correo',
                                  onPressed: _submitEmailUpdate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Cambiar contraseña
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        title: const Text('Cambiar Contraseña'),
                        trailing: Icon(
                          _showPasswordEditor
                              ? Icons.expand_less_outlined
                              : Icons.expand_more_outlined,
                        ),
                        onTap: () =>
                            setState(() => _showPasswordEditor = !_showPasswordEditor),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    if (_showPasswordEditor) ...[
                      const SizedBox(height: 16),
                      SimpleForm(
                        formKey: _passwordFormKey,
                        children: [
                          CustomTextField(
                            controller: _currentPasswordCtrl,
                            label: 'Contraseña Actual',
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            validator: Validators.validateNotEmpty,
                          ),
                          CustomTextField(
                            controller: _newPasswordCtrl,
                            label: 'Nueva Contraseña',
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            validator: (v) => Validators.differentPassword(v, _currentPasswordCtrl.text),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {}),
                          ),
                          CustomTextField(
                            controller: _confirmPasswordCtrl,
                            label: 'Confirmar Nueva Contraseña',
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            validator: (v) => Validators.confirmPassword(v, _newPasswordCtrl.text),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _showPasswordEditor = false),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  label: 'Actualizar Contraseña',
                                  onPressed: _submitPasswordUpdate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
