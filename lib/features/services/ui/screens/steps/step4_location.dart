import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import '../../bloc/service_publish_bloc.dart';
import '../../widgets/map_address_picker.dart';
import '../../../domain/entities/service_address.dart';

class Step4Location extends StatelessWidget {
  const Step4Location({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<ServicePublishBloc, ServicePublishState>(
      builder: (context, state) {
        final address = state.address;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Dónde es el servicio?',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Confirma tu dirección y ubica el punto exacto en el mapa.',
                style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              
              MapAddressPicker(
                initialPosition: address.latitude != null && address.longitude != null
                    ? LatLng(address.latitude!, address.longitude!)
                    : null,
                onPositionChanged: (pos) => _update(context, address.copyWith(latitude: pos.latitude, longitude: pos.longitude)),
              ),
              
              const SizedBox(height: 24),
              
              CustomTextField(
                controller: TextEditingController(text: address.addressLine1)..selection = TextSelection.fromPosition(TextPosition(offset: address.addressLine1.length)),
                label: 'Dirección (Calle / Carrera)',
                hint: 'Ej: Calle 10 # 20-30',
                onChanged: (v) => _update(context, address.copyWith(addressLine1: v)),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: TextEditingController(text: address.neighborhood)..selection = TextSelection.fromPosition(TextPosition(offset: address.neighborhood?.length ?? 0)),
                      label: 'Barrio',
                      onChanged: (v) => _update(context, address.copyWith(neighborhood: v)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: TextEditingController(text: address.city)..selection = TextSelection.fromPosition(TextPosition(offset: address.city.length)),
                      label: 'Ciudad',
                      onChanged: (v) => _update(context, address.copyWith(city: v)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: TextEditingController(text: address.addressLine2)..selection = TextSelection.fromPosition(TextPosition(offset: address.addressLine2?.length ?? 0)),
                label: 'Apto / Interior / Referencia (Opcional)',
                onChanged: (v) => _update(context, address.copyWith(addressLine2: v)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _update(BuildContext context, ServiceAddress address) {
    context.read<ServicePublishBloc>().add(
      ServicePublishUpdateDraftEvent(address: address),
    );
  }
}

extension on ServiceAddress {
  ServiceAddress copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? neighborhood,
    double? latitude,
    double? longitude,
  }) {
    return ServiceAddress(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
