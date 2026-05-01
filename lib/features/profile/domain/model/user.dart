import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un usuario.
class User extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final bool isActive;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.isActive = true,
    this.onboardingCompleted = false,
    this.createdAt,
    this.lastLogin,
  });

  String get fullName {
    final parts = <String>[];
    if (firstName?.isNotEmpty ?? false) parts.add(firstName!);
    if (lastName?.isNotEmpty ?? false) parts.add(lastName!);
    return parts.isEmpty ? 'Sin nombre' : parts.join(' ');
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      isActive: (map['is_active'] as bool?) ?? true,
      onboardingCompleted: (map['onboarding_completed'] as bool?) ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      lastLogin: map['last_login'] != null
          ? DateTime.tryParse(map['last_login'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, phone, firstName, lastName, isActive, onboardingCompleted];
}
