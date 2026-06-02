import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import '../bloc/review_bloc.dart';

class RatingScreen extends StatefulWidget {
  final String bookingId;
  final String serviceTitle;
  final String providerName;

  const RatingScreen({
    super.key,
    required this.bookingId,
    required this.serviceTitle,
    required this.providerName,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
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
            comment: _commentController.text,
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
            const SnackBar(content: Text('¡Gracias por tu calificación!'), backgroundColor: AppTheme.primary),
          );
          Navigator.pop(context, true);
        }
        if (state.status == ReviewStatus.error && state.errorMessage != null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppTheme.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Calificar Servicio'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.stars_rounded, size: 80, color: AppTheme.primarySoft),
              const SizedBox(height: 24),
              Text(
                '¿Cómo fue tu experiencia con ${widget.providerName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.serviceTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 40),
              
              // Selector de estrellas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final selected = index < _rating;
                  return IconButton(
                    onPressed: () => setState(() => _rating = index + 1),
                    padding: const EdgeInsets.all(8),
                    iconSize: 40,
                    tooltip: '${index + 1} estrella${index == 0 ? '' : 's'}',
                    icon: Icon(
                      selected ? Icons.star : Icons.star_border,
                      color: selected ? Colors.amber : AppTheme.textTertiary,
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 40),
              
              CustomTextField(
                label: 'Tu comentario (opcional)',
                controller: _commentController,
                hint: 'Cuéntanos qué tal te pareció el servicio...',
                maxLines: 4,
              ),
              
              const SizedBox(height: 48),
              
              BlocBuilder<ReviewBloc, ReviewState>(
                builder: (context, state) {
                  final isSubmitting = state.status == ReviewStatus.loading;
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
