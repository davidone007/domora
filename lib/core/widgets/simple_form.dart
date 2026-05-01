import 'package:flutter/material.dart';

/// Envoltorio simple para formularios. Agrupa hijos con espaciado consistente
/// y expone una `GlobalKey<FormState>` para validación.
class SimpleForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const SimpleForm({
    super.key,
    required this.formKey,
    required this.children,
    this.spacing = 16,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i != children.length - 1) {
        spaced.add(SizedBox(height: spacing));
      }
    }

    return Padding(
      padding: padding,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: spaced,
        ),
      ),
    );
  }
}
