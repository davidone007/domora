import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/utils/constants.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.primary,
                size: 80,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '¡Pago Exitoso!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu servicio ha sido confirmado y el aseador ha sido notificado. Puedes ver el estado en la sección de Solicitudes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const Spacer(),
            CustomButton(
              label: 'Ir a Mis Solicitudes',
              onPressed: () {
                context.go(AppConstants.routeMyServices);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
