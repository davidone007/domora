import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/utils/constants.dart';

class ProviderHomePage extends StatelessWidget {
  const ProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Domora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppConstants.routeProfile),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido, proveedor 🛠️',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(email, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.handyman_outlined,
                      size: 32, color: theme.colorScheme.secondary),
                  const SizedBox(height: 12),
                  Text('Panel del proveedor',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Aquí podrás ver solicitudes de servicio, gestionar propuestas y administrar tu portafolio.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('Ver mi perfil'),
              onPressed: () => context.push(AppConstants.routeProfile),
            ),
          ],
        ),
      ),
    );
  }
}
