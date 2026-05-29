import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:domora/core/error/error_mapper_singleton.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/injection_container.dart' as di;
import 'package:domora/core/network/network_info.dart';
import 'package:domora/core/navigation/app_router.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/web_utils_stub.dart'
  if (dart.library.html) 'package:domora/core/utils/web_utils.dart';

import 'package:domora/features/notifications/ui/bloc/notification_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localización para fechas (Intl)
  await initializeDateFormatting('es_CO', null);

  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
  }

  // Carga de variables de entorno desde .env (declarado como asset).
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Inicializar Contenedor de Inyección de Dependencias
  await di.init();

  // Compatibilidad con el Singleton actual de errores
  ErrorMapperSingleton.initialize(di.sl<FailureMapper>());

  // Manejo de fragmentos de autenticación en web
  await handleAuthRedirectFragment(Supabase.instance.client);

  runApp(
    BlocProvider(
      create: (_) => di.sl<NotificationBloc>()..add(const FetchNotificationsEvent()),
      child: const DomoraApp(),
    ),
  );
}

class DomoraApp extends StatelessWidget {
  const DomoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Domora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CO'),
      ],
      routerConfig: buildRouter(networkInfo: di.sl<NetworkInfo>()),
    );
  }
}
