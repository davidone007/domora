import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de texto reutilizable con etiqueta, validación y soporte de
/// contraseña.
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final TextInputAction textInputAction;
  final String? helperText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.helperText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            counterText: '',
            prefixIcon:
                widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
