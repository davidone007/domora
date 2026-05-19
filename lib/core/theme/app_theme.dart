import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual de Domora.
///
/// Paleta de marca: verde, blanco y negro.
/// Tipografía: DM Sans (vía google_fonts)
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Paleta de marca
  // ---------------------------------------------------------------------------
  /// Verde principal — botones, estados activos, acentos.
  static const Color primary = Color(0xFF4FBF67);

  /// Verde oscuro para hover / variante presionada.
  static const Color primaryDark = Color(0xFF3FA856);

  /// Verde muy claro para fondos suaves (chips activos, badges).
  static const Color primarySoft = Color(0xFFE8F7EC);

  /// Negro casi puro para títulos.
  static const Color textPrimary = Color(0xFF1C1C1E);

  /// Gris medio iOS para descripciones.
  static const Color textSecondary = Color(0xFF6E6E73);

  /// Gris claro para labels desactivados / hints.
  static const Color textTertiary = Color(0xFF9A9AA0);

  /// Gris muy claro para bordes de inputs.
  static const Color border = Color(0xFFE3E3E8);

  /// Gris para divisores sutiles.
  static const Color divider = Color(0xFFEFEFF4);

  /// Fondo general de la app.
  static const Color background = Color(0xFFFFFFFF);

  /// Fondo oscuro del header del dashboard y bottom nav.
  static const Color surfaceDark = Color(0xFF1C1C1E);

  /// Superficie de tarjetas.
  static const Color surface = Color(0xFFFFFFFF);

  /// Rojo de error.
  static const Color error = Color(0xFFE5484D);

  /// Verde para indicadores de éxito (igual al primary, pero expuesto aparte
  /// para que el código de UI no dependa de que primary == success).
  static const Color success = Color(0xFF4FBF67);

  // ---------------------------------------------------------------------------
  // Radios y tamaños recurrentes
  // ---------------------------------------------------------------------------
  static const double radiusInput = 16.0;
  static const double radiusButton = 28.0;
  static const double radiusCard = 20.0;
  static const double buttonHeight = 56.0;

  // ---------------------------------------------------------------------------
  // Tema claro (único por ahora)
  // ---------------------------------------------------------------------------
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    final textTheme = GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.dmSans(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.6,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.45,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: primary,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 22),
      ),

      // -----------------------------------------------------------------------
      // Inputs — estilo "outlined con label flotante" del referente.
      // El label vive dentro del borde y se posiciona en la parte superior
      // cuando hay valor o foco, rompiendo visualmente el stroke.
      // -----------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: GoogleFonts.dmSans(
          color: textTertiary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.dmSans(
          color: textTertiary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.dmSans(
          color: textTertiary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        helperStyle: GoogleFonts.dmSans(
          color: textSecondary,
          fontSize: 12,
        ),
        errorStyle: GoogleFonts.dmSans(
          color: error,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: error, width: 1.6),
        ),
      ),

      // -----------------------------------------------------------------------
      // Botones primarios — píldora verde 56 px de alto.
      // -----------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withOpacity(0.5),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Botones secundarios — outline verde con la misma forma.
      // -----------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(buttonHeight),
          side: const BorderSide(color: primary, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // TextButton — para enlaces "¿Olvidaste tu contraseña?", "Regístrate".
      // -----------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Checkbox — verde con tick blanco, esquinas suaves.
      // -----------------------------------------------------------------------
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.white;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: border, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      // -----------------------------------------------------------------------
      // Cards y divisores.
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      // -----------------------------------------------------------------------
      // SnackBar oscuro flotante.
      // -----------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceDark,
        contentTextStyle: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
