import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/core/widgets/rating_stars.dart';
import '../bloc/review_bloc.dart';

class RatingScreen extends StatefulWidget {
  final String bookingId;
  final String serviceTitle;

  /// Nombre de la otra parte (proveedor o cliente según `reviewerType`).
  final String otherPartyName;

  /// 'client' (default): cliente califica al proveedor.
  /// 'provider': proveedor califica al cliente.
  final String reviewerType;

  /// ID del usuario que envía la reseña. null = legado.
  final String? reviewerId;

  const RatingScreen({
    super.key,
    required this.bookingId,
    required this.serviceTitle,
    required this.otherPartyName,
    this.reviewerType = 'client',
    this.reviewerId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  /// Rating general obligatorio (0 = sin seleccionar).
  int _rating = 0;

  /// Sub-ratings opcionales (0 = sin seleccionar → se envían como null).
  int _punctualityRating = 0;
  int _qualityRating = 0;
  int _communicationRating = 0;

  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndSubmit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enviar calificación'),
        content: const Text(
          'Una vez enviada, no podrás modificarla. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, enviar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    context.read<ReviewBloc>().add(
          SendReviewRequestedEvent(
            bookingId: widget.bookingId,
            rating: _rating,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
            punctualityRating:
                _punctualityRating == 0 ? null : _punctualityRating,
            qualityRating: _qualityRating == 0 ? null : _qualityRating,
            communicationRating:
                _communicationRating == 0 ? null : _communicationRating,
            reviewerType: widget.reviewerType,
            reviewerId: widget.reviewerId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state.status == ReviewStatus.success) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Gracias por tu calificación!'),
              backgroundColor: AppTheme.primary,
            ),
          );
          Navigator.pop(context, true);
        }
        if (state.status == ReviewStatus.error &&
            state.errorMessage != null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.reviewerType == 'provider'
                ? 'Calificar Cliente'
                : 'Calificar Servicio',
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                widget.reviewerType == 'provider'
                    ? Icons.handshake_outlined
                    : Icons.stars_rounded,
                size: 80,
                color: AppTheme.primarySoft,
              ),
              const SizedBox(height: 24),
              Text(
                widget.reviewerType == 'provider'
                    ? '¿Cómo fue trabajar con ${widget.otherPartyName}?'
                    : '¿Cómo fue tu experiencia con ${widget.otherPartyName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.serviceTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),

              // ── Rating general ──────────────────────────────────────────
              const Text(
                'Calificación general',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 12),
              RatingStars(
                rating: _rating.toDouble(),
                size: 44,
                onRatingChanged: (value) =>
                    setState(() => _rating = value),
              ),

              const SizedBox(height: 32),

              // ── Sub-ratings opcionales (expandible) ─────────────────────
              _SubRatingsSection(
                punctualityRating: _punctualityRating,
                qualityRating: _qualityRating,
                communicationRating: _communicationRating,
                onPunctualityChanged: (v) =>
                    setState(() => _punctualityRating = v),
                onQualityChanged: (v) =>
                    setState(() => _qualityRating = v),
                onCommunicationChanged: (v) =>
                    setState(() => _communicationRating = v),
              ),

              const SizedBox(height: 28),

              // ── Comentario ───────────────────────────────────────────────
              CustomTextField(
                label: 'Tu comentario (opcional)',
                controller: _commentController,
                hint: 'Cuéntanos qué tal te pareció el servicio...',
                maxLines: 4,
              ),

              const SizedBox(height: 36),

              // ── Botón enviar ─────────────────────────────────────────────
              BlocBuilder<ReviewBloc, ReviewState>(
                builder: (context, state) {
                  final isSubmitting =
                      state.status == ReviewStatus.loading;
                  return CustomButton(
                    label: 'Enviar Calificación',
                    isLoading: isSubmitting,
                    onPressed: (_rating == 0 || isSubmitting)
                        ? null
                        : () => _confirmAndSubmit(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Sección colapsable con los tres sub-ratings opcionales.
class _SubRatingsSection extends StatefulWidget {
  const _SubRatingsSection({
    required this.punctualityRating,
    required this.qualityRating,
    required this.communicationRating,
    required this.onPunctualityChanged,
    required this.onQualityChanged,
    required this.onCommunicationChanged,
  });

  final int punctualityRating;
  final int qualityRating;
  final int communicationRating;
  final ValueChanged<int> onPunctualityChanged;
  final ValueChanged<int> onQualityChanged;
  final ValueChanged<int> onCommunicationChanged;

  @override
  State<_SubRatingsSection> createState() => _SubRatingsSectionState();
}

class _SubRatingsSectionState extends State<_SubRatingsSection> {
  bool _expanded = false;

  bool get _hasAny =>
      widget.punctualityRating > 0 ||
      widget.qualityRating > 0 ||
      widget.communicationRating > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Header colapsable
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
                bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _hasAny
                          ? AppTheme.primarySoft
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.tune_outlined,
                      size: 18,
                      color:
                          _hasAny ? AppTheme.primary : AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detallar calificación',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _hasAny
                              ? 'Calificación detallada añadida'
                              : 'Opcional — puntualidad, calidad, comunicación',
                          style: TextStyle(
                            fontSize: 11,
                            color: _hasAny
                                ? AppTheme.primary
                                : AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Contenido expandido
          if (_expanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                children: [
                  _SubRatingRow(
                    label: 'Puntualidad',
                    icon: Icons.schedule_outlined,
                    rating: widget.punctualityRating,
                    onChanged: widget.onPunctualityChanged,
                  ),
                  const SizedBox(height: 16),
                  _SubRatingRow(
                    label: 'Calidad del trabajo',
                    icon: Icons.workspace_premium_outlined,
                    rating: widget.qualityRating,
                    onChanged: widget.onQualityChanged,
                  ),
                  const SizedBox(height: 16),
                  _SubRatingRow(
                    label: 'Comunicación',
                    icon: Icons.chat_outlined,
                    rating: widget.communicationRating,
                    onChanged: widget.onCommunicationChanged,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Fila con icono, etiqueta y selector de estrellas para un sub-rating.
class _SubRatingRow extends StatelessWidget {
  const _SubRatingRow({
    required this.label,
    required this.icon,
    required this.rating,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        RatingStars(
          rating: rating.toDouble(),
          size: 28,
          onRatingChanged: onChanged,
        ),
      ],
    );
  }
}
