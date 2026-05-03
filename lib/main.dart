import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/error/error_mapper_singleton.dart';
import 'package:domora/core/navigation/app_router.dart';
import 'package:domora/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga de variables de entorno desde .env (declarado como asset).
  await dotenv.load(fileName: '.env');

  // Inicializar sistema de manejo de errores
  ErrorMapperSingleton.initialize(ErrorMapperSingleton.createDefault());

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    // Persistencia de sesión: por defecto Supabase Flutter ya guarda la sesión
    // de forma segura.
  );

  runApp(const DomoraApp());
}

class DomoraApp extends StatelessWidget {
  const DomoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Domora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: buildRouter(),
    );
  }
}
