import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:domora/core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Modelo de indicativo de país (privado al widget).
// ---------------------------------------------------------------------------
class _DialCode {
  final String flag;
  final String code;
  final String name;

  const _DialCode({required this.flag, required this.code, required this.name});
}

/// Lista de indicativos soportados — América Latina, España y EE.UU.
const _kDialCodes = <_DialCode>[
  _DialCode(flag: '🇨🇴', code: '+57',  name: 'Colombia'),
  _DialCode(flag: '🇻🇪', code: '+58',  name: 'Venezuela'),
  _DialCode(flag: '🇲🇽', code: '+52',  name: 'México'),
  _DialCode(flag: '🇵🇪', code: '+51',  name: 'Perú'),
  _DialCode(flag: '🇨🇱', code: '+56',  name: 'Chile'),
  _DialCode(flag: '🇦🇷', code: '+54',  name: 'Argentina'),
  _DialCode(flag: '🇪🇨', code: '+593', name: 'Ecuador'),
  _DialCode(flag: '🇧🇴', code: '+591', name: 'Bolivia'),
  _DialCode(flag: '🇵🇾', code: '+595', name: 'Paraguay'),
  _DialCode(flag: '🇺🇾', code: '+598', name: 'Uruguay'),
  _DialCode(flag: '🇧🇷', code: '+55',  name: 'Brasil'),
  _DialCode(flag: '🇪🇸', code: '+34',  name: 'España'),
  _DialCode(flag: '🇺🇸', code: '+1',   name: 'Estados Unidos'),
];

// ---------------------------------------------------------------------------
// Widget principal
// ---------------------------------------------------------------------------

/// Campo de teléfono con selector de indicativo de país obligatorio.
///
/// El indicativo se muestra como prefijo pulsable dentro del campo estándar
/// de la app. Al pulsarlo se abre un modal inferior con la lista de países.
///
/// **Responsabilidades del padre:**
/// - Crear y gestionar [controller] (sólo el número local, sin indicativo).
/// - Mantener el indicativo seleccionado en su propio estado y pasarlo en
///   [dialCode].
/// - Escuchar cambios en [onDialCodeChanged] para actualizar su estado.
/// - Al enviar el formulario, concatenar: `'${dialCode} ${controller.text.trim()}'`.
///
/// **Sin cambios en la capa de dominio ni en Supabase**: el teléfono se
/// almacena como cadena completa en el campo `phone` (p.ej. `+57 3001234567`).
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.dialCode,
    required this.onDialCodeChanged,
    this.validator,
  });

  /// Controlador para el número local (sin indicativo).
  final TextEditingController controller;

  /// Indicativo actualmente seleccionado (p.ej. `'+57'`).
  final String dialCode;

  /// Invocado cuando el usuario elige un indicativo diferente.
  final void Function(String dialCode) onDialCodeChanged;

  /// Validador para el número local. Usar [Validators.phoneNumber].
  final String? Function(String?)? validator;

  // ---------------------------------------------------------------------------

  _DialCode get _current => _kDialCodes.firstWhere(
        (c) => c.code == dialCode,
        orElse: () => _kDialCodes.first,
      );

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<_DialCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(selected: _current),
    );
    if (picked != null) onDialCodeChanged(picked.code);
  }

  @override
  Widget build(BuildContext context) {
    final country = _current;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-]')),
      ],
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Teléfono',
        hintText: '300 123 4567',
        prefixIcon: const Icon(
          Icons.phone_outlined,
          size: 20,
          color: AppTheme.textTertiary,
        ),
        // El prefix vive DENTRO del campo, a la derecha del icono y antes
        // del texto. GestureDetector captura el tap para abrir el picker.
        prefix: GestureDetector(
          onTap: () => _openPicker(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  country.code,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hoja modal de selección de país
// ---------------------------------------------------------------------------

class _CountryPickerSheet extends StatelessWidget {
  const _CountryPickerSheet({required this.selected});

  final _DialCode selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Manija visual
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Título + botón cerrar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
            child: Row(
              children: [
                Text(
                  'Código de país',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista de países
          Expanded(
            child: ListView.builder(
              itemCount: _kDialCodes.length,
              itemBuilder: (context, i) {
                final item = _kDialCodes[i];
                final isSelected = item.code == selected.code;
                return ListTile(
                  leading: Text(item.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(item.name),
                  trailing: Text(
                    item.code,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppTheme.primarySoft,
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
