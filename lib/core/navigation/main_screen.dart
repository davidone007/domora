import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/utils/constants.dart';
import 'package:domora/features/auth/data/sources/auth_data_source.dart';

/// Pantalla inicial. Decide a dónde enviar al usuario:
/// - Sin sesión → login.
/// - Sesión + onboarding pendiente → onboarding.
/// - Sesión + onboarding completo → dashboard según rol.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;

    if (session == null) {
      if (mounted) context.go(AppConstants.routeLogin);
      return;
    }

    try {
      final ds = AuthDataSourceImpl(client);
      final userId = session.user.id;
      final role = await ds.getUserRole(userId);
      final onboardingDone = await ds.isOnboardingCompleted(userId);

      if (!onboardingDone) {
        if (mounted) context.go(AppConstants.routeOnboarding);
        return;
      }

      if (role == AppConstants.roleProvider) {
        if (mounted) context.go(AppConstants.routeProviderHome);
      } else {
        if (mounted) context.go(AppConstants.routeClientHome);
      }
    } catch (_) {
      if (mounted) context.go(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.cottage_outlined,
                  color: Colors.white, size: 38),
            ),
            const SizedBox(height: 24),
            Text('Domora', style: theme.textTheme.displayMedium),
            const SizedBox(height: 8),
            Text('Servicios para tu hogar', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    );
  }
}
