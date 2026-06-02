import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import '../../bloc/service_publish_bloc.dart';
import '../../widgets/multi_image_picker.dart';
import '../../widgets/image_thumbnail_grid.dart';

class Step2GeneralInfo extends StatefulWidget {
  const Step2GeneralInfo({super.key});

  @override
  State<Step2GeneralInfo> createState() => _Step2GeneralInfoState();
}

class _Step2GeneralInfoState extends State<Step2GeneralInfo> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ServicePublishBloc>().state;
    _titleController = TextEditingController(text: state.title);
    _descriptionController = TextEditingController(text: state.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa un título';
    if (v.length < 5) return 'Mínimo 5 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ServicePublishBloc, ServicePublishState>(
      buildWhen: (prev, curr) =>
          prev.images != curr.images ||
          prev.primaryImageIndex != curr.primaryImageIndex,
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
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _titleController,
                label: 'Título de la solicitud',
                hint: 'Ej: Limpieza profunda de fin de semana',
                validator: _validateTitle,
                onChanged: (v) => context
                    .read<ServicePublishBloc>()
                    .add(ServicePublishUpdateDraftEvent(title: v)),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _descriptionController,
                label: 'Descripción detallada',
                hint:
                    'Ej: Necesito énfasis en la cocina y el balcón. Tengo una mascota pequeña.',
                maxLines: 6,
                onChanged: (v) => context
                    .read<ServicePublishBloc>()
                    .add(ServicePublishUpdateDraftEvent(description: v)),
              ),

              const Divider(height: 48),

              Text(
                'Fotos del lugar (Opcional)',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sube fotos para que los aseadores entiendan mejor el trabajo.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),

              MultiImagePicker(
                onImageSelected: (image) {
                  context
                      .read<ServicePublishBloc>()
                      .add(ServicePublishAddImageEvent(image));
                },
              ),

              const SizedBox(height: 16),

              ImageThumbnailGrid(
                images: state.images,
                primaryIndex: state.primaryImageIndex,
                onRemove: (index) {
                  context
                      .read<ServicePublishBloc>()
                      .add(ServicePublishRemoveImageEvent(index));
                },
                onSetPrimary: (index) {
                  context
                      .read<ServicePublishBloc>()
                      .add(ServicePublishSetPrimaryImageEvent(index));
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
