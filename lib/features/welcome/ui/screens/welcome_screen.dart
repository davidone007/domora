import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:domora/core/utils/constants.dart';
import 'package:domora/features/welcome/ui/models/welcome_page_data.dart';

/// Carrusel de bienvenida que se muestra a usuarios sin sesión antes
/// de llegar al login.
///
/// No persiste nada por sí mismo: cuando el usuario presiona "Omitir" o
/// avanza más allá de la última página, navegamos a /login.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // ---------------------------------------------------------------------------
  // Constantes de diseño (vienen del spec)
  // ---------------------------------------------------------------------------
  static const _horizontalPadding = 24.0;
  static const _imageRadius = 28.0;
  static const _buttonRadius = 16.0;
  static const _buttonHeight = 56.0;
  static const _imageHeightFactor = 0.45;

  static const _colorPrimary = Color(0xFF4FBF67);
  static const _colorTitle = Color(0xFF1C1C1E);
  static const _colorDescription = Color(0xFF6E6E73);
  static const _colorDot = Color(0xFFD1D1D6);
  static const _skipOverlay = Color(0x59000000); // rgba(0,0,0,0.35)

  // ---------------------------------------------------------------------------
  // Contenido del carrusel
  // ---------------------------------------------------------------------------
  static const _pages = <WelcomePageData>[
    WelcomePageData(
      imageAsset: 'assets/images/welcome/welcome_1.png',
      title: 'Profesionales que\ninspiran seguridad',
      description:
          'Todos nuestros técnicos tienen identidad verificada y reputación basada en reseñas de servicios hechos.',
      buttonLabel: 'Comenzar',
    ),
    WelcomePageData(
      imageAsset: 'assets/images/welcome/welcome_2.png',
      title: '¿Sin confianza\npara contratar?',
      description:
          'Abrirle la puerta a un extraño es riesgoso. El voz a voz es lento y no te da garantías.',
      buttonLabel: 'Siguiente',
    ),
  ];

  final _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPrimaryPressed() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    context.go(AppConstants.routeLogin);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * _imageHeightFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // -----------------------------------------------------------------
            // Sección de imagen + botón "Omitir"
            // El PageView vive aquí para que solo la imagen + textos se animen,
            // mientras el botón inferior permanece estable.
            // -----------------------------------------------------------------
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (_, index) =>
                    _WelcomePageContent(
                      data: _pages[index],
                      imageHeight: imageHeight,
                      horizontalPadding: _horizontalPadding,
                      imageRadius: _imageRadius,
                      onSkip: _goToLogin,
                      skipOverlay: _skipOverlay,
                      titleColor: _colorTitle,
                      descriptionColor: _colorDescription,
                      currentIndex: _currentIndex,
                      totalPages: _pages.length,
                      dotColor: _colorDot,
                    ),
              ),
            ),

            // -----------------------------------------------------------------
            // Botón principal — fuera del PageView para que su texto cambie
            // suavemente sin moverse con el swipe.
            // -----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                28,
                _horizontalPadding,
                24,
              ),
              child: SizedBox(
                width: double.infinity,
                height: _buttonHeight,
                child: ElevatedButton(
                  onPressed: _onPrimaryPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_buttonRadius),
                    ),
                  ),
                  child: Text(
                    _pages[_currentIndex].buttonLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Contenido de cada página: imagen, título, descripción y dots.
// Se separa para mantener el build principal corto y legible.
// -----------------------------------------------------------------------------
class _WelcomePageContent extends StatelessWidget {
  const _WelcomePageContent({
    required this.data,
    required this.imageHeight,
    required this.horizontalPadding,
    required this.imageRadius,
    required this.onSkip,
    required this.skipOverlay,
    required this.titleColor,
    required this.descriptionColor,
    required this.currentIndex,
    required this.totalPages,
    required this.dotColor,
  });

  final WelcomePageData data;
  final double imageHeight;
  final double horizontalPadding;
  final double imageRadius;
  final VoidCallback onSkip;
  final Color skipOverlay;
  final Color titleColor;
  final Color descriptionColor;
  final int currentIndex;
  final int totalPages;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          // Imagen con botón "Omitir" superpuesto.
          ClipRRect(
            borderRadius: BorderRadius.circular(imageRadius),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: imageHeight,
                  child: Image.asset(
                    data.imageAsset,
                    fit: BoxFit.cover,
                    // Si el asset aún no existe, mostramos un placeholder
                    // suave en lugar de romper la pantalla en desarrollo.
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFEFEFF4),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Color(0xFFB0B0B8),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Material(
                    color: skipOverlay,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onSkip,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Text(
                          'Omitir',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Título — separación de 32 px tras la imagen.
          const SizedBox(height: 32),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: titleColor,
            ),
          ),

          // Descripción — separación de 12 px tras el título.
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: descriptionColor,
              ),
            ),
          ),

          // Dots de paginación — separación de 20 px tras la descripción.
          const SizedBox(height: 20),
          _PaginationDots(
            currentIndex: currentIndex,
            totalPages: totalPages,
            color: dotColor,
          ),

          // Empuja el contenido hacia arriba; el botón principal vive
          // fuera del PageView en la pantalla padre.
          const Spacer(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dots con la activa en forma de píldora alargada (18 x 6 px).
// -----------------------------------------------------------------------------
class _PaginationDots extends StatelessWidget {
  const _PaginationDots({
    required this.currentIndex,
    required this.totalPages,
    required this.color,
  });

  final int currentIndex;
  final int totalPages;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(right: i == totalPages - 1 ? 0 : 6),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
