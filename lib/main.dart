import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/error/error_mapper_singleton.dart';
import 'package:domora/core/error/error_config.dart';
import 'package:domora/core/error/error_logger.dart';
import 'package:domora/core/network/data/network_info_impl.dart';
import 'package:domora/core/error/data/error_mapper_impl.dart';
import 'package:domora/core/navigation/app_router.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/web_utils_stub.dart'
  if (dart.library.html) 'package:domora/core/utils/web_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga de variables de entorno desde .env (declarado como asset).
  await dotenv.load(fileName: '.env');

  // Inicializar sistema de manejo de errores: crear la implementación
  // concreta en la capa de aplicación y pasarla al singleton.
  final config = ErrorConfig.auto();
  final logger = ErrorLogger(config);
  final mapper = ErrorMapperImpl(logger: logger, config: config);
  ErrorMapperSingleton.initialize(mapper);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    // Persistencia de sesión: por defecto Supabase Flutter ya guarda la sesión
    // de forma segura.
  );

  // Manejo de fragmentos de autenticación en web (p.ej. #access_token=...)
  // Evita que el enrutador falle cuando Supabase deja tokens en el hash.
  await handleAuthRedirectFragment(Supabase.instance.client);

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final healthUri = Uri.parse(supabaseUrl).resolve('/auth/v1/health');
  final networkInfo = NetworkInfoImpl(probeUri: healthUri);

  runApp(DomoraApp(networkInfo: networkInfo));
}

class DomoraApp extends StatelessWidget {
  final NetworkInfoImpl networkInfo;

  const DomoraApp({super.key, required this.networkInfo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Domora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: buildRouter(networkInfo: networkInfo),
    );
  }
}
