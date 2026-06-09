import 'package:domora/core/services/fcm_service.dart';

/// UseCase que inicializa el servicio FCM y registra los listeners de
/// notificaciones push. Al existir como use case, los BLoCs no necesitan
/// importar [FcmService] directamente, respetando la regla
/// BLoC → UseCase → Servicio/Infraestructura.
class InitializeFcmUseCase {
  final FcmService _fcmService;

  InitializeFcmUseCase(this._fcmService);

  Future<void> call() => _fcmService.initialize();
}
