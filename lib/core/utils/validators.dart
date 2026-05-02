/// Validadores de formularios reutilizables.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9\s\-]{7,20}$');
  static final RegExp _onlyDigits = RegExp(r'^\d+$');
  static final RegExp _decimalRegex = RegExp(r'^\d+([\.,]\d{1,2})?$');

  /// Email obligatorio con formato válido.
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El correo es obligatorio';
    if (!_emailRegex.hasMatch(v)) return 'Ingresa un correo válido';
    return null;
  }

  /// Contraseña: mínimo 8 caracteres, al menos una letra y un número.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'La contraseña es obligatoria';
    if (v.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!RegExp(r'[A-Za-z]').hasMatch(v)) {
      return 'Debe contener al menos una letra';
    }
    if (!RegExp(r'\d').hasMatch(v)) {
      return 'Debe contener al menos un número';
    }
    return null;
  }

  /// Confirmación de contraseña.
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  /// Nombre o apellido (no vacío, al menos 2 caracteres).
  static String? name(String? value, {String label = 'nombre'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El $label es obligatorio';
    if (v.length < 2) return 'El $label debe tener al menos 2 caracteres';
    return null;
  }

  /// Teléfono con formato razonable.
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El teléfono es obligatorio';
    if (!_phoneRegex.hasMatch(v)) return 'Ingresa un teléfono válido';
    return null;
  }

  /// Campo obligatorio genérico.
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  /// Años de experiencia: entero >= 0.
  static String? yearsExperience(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Los años de experiencia son obligatorios';
    if (!_onlyDigits.hasMatch(v)) return 'Solo se permiten números enteros';
    final n = int.tryParse(v);
    if (n == null || n < 0) return 'Ingresa un número válido';
    if (n > 80) return 'El valor parece demasiado alto';
    return null;
  }

  /// Tarifa por hora: número decimal positivo.
  static String? hourlyRate(String? value) {
    final v = value?.trim().replaceAll(',', '.') ?? '';
    if (v.isEmpty) return 'La tarifa por hora es obligatoria';
    if (!_decimalRegex.hasMatch(value?.trim() ?? '')) {
      return 'Ingresa un número válido';
    }
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'La tarifa debe ser mayor a 0';
    return null;
  }

  /// Bio opcional pero con máximo de caracteres.
  static String? bio(String? value, {int max = 500}) {
    final v = value?.trim() ?? '';
    if (v.length > max) return 'Máximo $max caracteres';
    return null;
  }

  /// Número local de teléfono, sin indicativo de país.
  ///
  /// Se usa junto a [PhoneField]: el indicativo lo gestiona el widget y el
  /// padre lo concatena antes de enviar al dominio.
  static String? phoneNumber(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El número de teléfono es obligatorio';
    final digits = v.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\d+$').hasMatch(digits)) {
      return 'Solo se permiten dígitos, espacios y guiones';
    }
    if (digits.length < 6 || digits.length > 15) {
      return 'Ingresa un número válido (6–15 dígitos)';
    }
    return null;
  }
}
