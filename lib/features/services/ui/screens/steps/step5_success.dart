import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_button.dart';

class Step5Success extends StatelessWidget {
  const Step5Success({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppTheme.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 80,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '¡Orden Publicada!',
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu solicitud de limpieza ha sido enviada con éxito. Pronto empezarás a recibir cotizaciones de nuestros aseadores.',
            style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          CustomButton(
            label: 'Volver al Inicio',
            onPressed: () => context.go('/client-home'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
