// Parámetros de dominio para operaciones de perfil.
//
// Viven en `domain/params/` para que tanto los UseCases como el
// `ProfileRepository` (abstracto e impl) puedan importarlos sin crear
// dependencias cruzadas entre capas.

// ---------------------------------------------------------------------------
// Usuario
// ---------------------------------------------------------------------------

/// Parámetros para actualizar los campos básicos del usuario.
class UpdateUserFieldsParams {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? phone;

  const UpdateUserFieldsParams({
    required this.userId,
    this.firstName,
    this.lastName,
    this.phone,
  });
}

// ---------------------------------------------------------------------------
// Perfil cliente
// ---------------------------------------------------------------------------

/// Parámetros para actualizar el perfil de un cliente.
class UpdateClientProfileParams {
  final String userId;
  final String? bio;
  final String? avatarUrl;

  const UpdateClientProfileParams({
    required this.userId,
    this.bio,
    this.avatarUrl,
  });
}

// ---------------------------------------------------------------------------
// Perfil proveedor
// ---------------------------------------------------------------------------

/// Parámetros para actualizar el perfil de un proveedor.
class UpdateProviderProfileParams {
  final String userId;
  final int? yearsExperience;
  final double? hourlyRate;
  final bool? isAvailable;
  final String? bio;
  final String? avatarUrl;

  const UpdateProviderProfileParams({
    required this.userId,
    this.yearsExperience,
    this.hourlyRate,
    this.isAvailable,
    this.bio,
    this.avatarUrl,
  });
}

// ---------------------------------------------------------------------------
// Dirección
// ---------------------------------------------------------------------------

/// Parámetros para actualizar la dirección principal de un proveedor.
class UpdateProviderAddressParams {
  final String userId;
  final String addressLine1;
  final String? addressLine2;
  final String department;
  final String city;
  final String? neighborhood;

  const UpdateProviderAddressParams({
    required this.userId,
    required this.addressLine1,
    this.addressLine2,
    required this.department,
    required this.city,
    this.neighborhood,
  });
}
