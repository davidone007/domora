import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/navigation/bloc/splash_bloc.dart';

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateState) {
          context.go(state.route);
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
