import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import '../../bloc/service_publish_bloc.dart';
import '../../widgets/service_counter_input.dart';
import '../../../domain/entities/cleaning_service_detail.dart';

class Step1PlaceDetails extends StatelessWidget {
  const Step1PlaceDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<ServicePublishBloc, ServicePublishState>(
      builder: (context, state) {
        final details = state.details;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Cómo es el lugar?',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Cuéntanos sobre los espacios que necesitan limpieza.',
                style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              
              ServiceCounterInput(
                label: 'Habitaciones',
                icon: Icons.bed_outlined,
                value: details.bedrooms,
                onChanged: (v) => _update(context, details.copyWith(bedrooms: v)),
              ),
              const SizedBox(height: 16),
              
              ServiceCounterInput(
                label: 'Baños',
                icon: Icons.bathtub_outlined,
                value: details.bathrooms,
                onChanged: (v) => _update(context, details.copyWith(bathrooms: v)),
              ),
              const SizedBox(height: 16),
              
              ServiceCounterInput(
                label: 'Salas / Comedores',
                icon: Icons.weekend_outlined,
                value: details.livingRooms,
                onChanged: (v) => _update(context, details.copyWith(livingRooms: v)),
              ),
              const SizedBox(height: 16),
              
              ServiceCounterInput(
                label: 'Cocinas',
                icon: Icons.kitchen_outlined,
                value: details.kitchens,
                onChanged: (v) => _update(context, details.copyWith(kitchens: v)),
              ),
              
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Incluye balcón / terraza'),
                value: details.includesBalcony,
                onChanged: (v) => _update(context, details.copyWith(includesBalcony: v ?? false)),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.primary,
              ),
              
              const Divider(height: 48),
              
              Text(
                'Insumos de limpieza',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Tengo mis propios implementos'),
                subtitle: const Text('Jabones, traperos, aspiradora, etc.'),
                value: details.hasOwnSupplies,
                onChanged: (v) => _update(context, details.copyWith(hasOwnSupplies: v)),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppTheme.primary,
              ),
              
              if (!details.hasOwnSupplies) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: TextEditingController(text: details.suppliesNotes),
                  label: 'Notas sobre insumos',
                  hint: '¿Qué le hace falta al aseador?',
                  maxLines: 3,
                  onChanged: (v) => _update(context, details.copyWith(suppliesNotes: v)),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _update(BuildContext context, CleaningServiceDetail details) {
    context.read<ServicePublishBloc>().add(
      ServicePublishUpdateDraftEvent(details: details),
    );
  }
}

extension on CleaningServiceDetail {
  CleaningServiceDetail copyWith({
    int? bathrooms,
    int? kitchens,
    int? bedrooms,
    int? livingRooms,
    bool? includesBalcony,
    bool? hasOwnSupplies,
    String? suppliesNotes,
  }) {
    return CleaningServiceDetail(
      bathrooms: bathrooms ?? this.bathrooms,
      kitchens: kitchens ?? this.kitchens,
      bedrooms: bedrooms ?? this.bedrooms,
      livingRooms: livingRooms ?? this.livingRooms,
      includesBalcony: includesBalcony ?? this.includesBalcony,
      hasOwnSupplies: hasOwnSupplies ?? this.hasOwnSupplies,
      suppliesNotes: suppliesNotes ?? this.suppliesNotes,
    );
  }
}
