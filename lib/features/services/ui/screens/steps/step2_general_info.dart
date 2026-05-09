import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import '../../bloc/service_publish_bloc.dart';

class Step2GeneralInfo extends StatelessWidget {
  const Step2GeneralInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<ServicePublishBloc, ServicePublishState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sobre tu solicitud',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Ponle un título atractivo y explica detalles adicionales.',
                style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              
              CustomTextField(
                controller: TextEditingController(text: state.title)..selection = TextSelection.fromPosition(TextPosition(offset: state.title.length)),
                label: 'Título de la solicitud',
                hint: 'Ej: Limpieza profunda de fin de semana',
                onChanged: (v) => context.read<ServicePublishBloc>().add(ServicePublishUpdateDraftEvent(title: v)),
              ),
              const SizedBox(height: 24),
              
              CustomTextField(
                controller: TextEditingController(text: state.description)..selection = TextSelection.fromPosition(TextPosition(offset: state.description?.length ?? 0)),
                label: 'Descripción detallada',
                hint: 'Ej: Necesito énfasis en la cocina y el balcón. Tengo una mascota pequeña.',
                maxLines: 6,
                onChanged: (v) => context.read<ServicePublishBloc>().add(ServicePublishUpdateDraftEvent(description: v)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
