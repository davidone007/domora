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

  static String? differentEmail(String? value, String currentEmail) {
    final v = value?.trim().toLowerCase() ?? '';
    final current = currentEmail.trim().toLowerCase();
    if (v.isEmpty) return 'El correo es obligatorio';
    if (!_emailRegex.hasMatch(v)) return 'Ingresa un correo válido';
    if (v == current) return 'No se puede cambiar por el mismo correo';
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

  static String? differentPassword(String? value, String currentPassword) {
    final v = value ?? '';
    if (v.isEmpty) return 'La contraseña es obligatoria';
    if (v == currentPassword) return 'No se puede cambiar por la misma contraseña';
    return password(v);
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

  static String? integerField(String? value, {required String fieldName, int? min, int? max}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName es obligatorio';
    if (!_onlyDigits.hasMatch(v)) return 'Solo se permiten números enteros';
    final parsed = int.tryParse(v);
    if (parsed == null) return 'Ingresa un número válido para $fieldName';
    if (min != null && parsed < min) return '$fieldName no puede ser menor que $min';
    if (max != null && parsed > max) return '$fieldName no puede ser mayor que $max';
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

  /// Línea de dirección obligatoria (mínimo 5 caracteres).
  static String? addressLine(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'La dirección es obligatoria';
    if (v.length < 5) return 'Ingresa una dirección más detallada';
    return null;
  }

  /// Ciudad obligatoria.
  static String? city(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'La ciudad es obligatoria';
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

  /// Alias para [email] validator.
  static String? validateEmail(String? value) => email(value);

  /// Alias para [password] validator.
  static String? validatePassword(String? value) => password(value);

  /// Alias para [phone] validator.
  static String? validatePhone(String? value) => phone(value);

  /// Alias para [required] validator.
  static String? validateNotEmpty(String? value, {String fieldName = 'Este campo'}) =>
      required(value, fieldName: fieldName);

  /// Número genérico (entero o decimal) para campos como experiencia o tarifa.
  static String? validateNumberField(String? value, String fieldName) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName es obligatorio';
    final num = double.tryParse(v.replaceAll(',', '.'));
    if (num == null) return 'Ingresa un número válido para $fieldName';
    if (num < 0) return '$fieldName no puede ser negativo';
    return null;
  }
}
