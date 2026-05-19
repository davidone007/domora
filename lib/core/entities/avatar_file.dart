import 'dart:typed_data';

/// Representa un archivo de avatar de forma independiente a la plataforma.
/// Definida en core/ para ser compartida entre los features onboarding y profile.
class AvatarFile {
  final String filename;
  final Uint8List bytes;

  const AvatarFile({required this.filename, required this.bytes});
}
