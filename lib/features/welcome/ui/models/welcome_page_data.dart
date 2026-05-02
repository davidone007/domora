/// Datos de una página del carrusel de bienvenida.
///
/// El carrusel es puramente presentacional: no escribe nada en la base de
/// datos, solo introduce al usuario antes de llegar al login.
class WelcomePageData {
  const WelcomePageData({
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });

  /// Ruta del asset de imagen, p. ej. `assets/images/welcome/welcome_1.jpg`.
  final String imageAsset;

  /// Título grande en negritas.
  final String title;

  /// Descripción gris debajo del título.
  final String description;

  /// Texto del botón inferior para esa página.
  /// Ej: "Comenzar" en la primera, "Siguiente" en la segunda.
  final String buttonLabel;
}
