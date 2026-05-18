import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import '../../bloc/address_picker_bloc.dart';
import '../../bloc/service_publish_bloc.dart';
import '../../widgets/map_address_picker.dart';
import '../../../domain/entities/geo_coordinates.dart';
import '../../../domain/entities/service_address.dart';

class Step4Location extends StatefulWidget {
  const Step4Location({super.key});

  @override
  State<Step4Location> createState() => _Step4LocationState();
}

class _Step4LocationState extends State<Step4Location> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AddressPickerBloc>()
          .add(const AddressPickerLoadCurrentLocationEvent());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    final query = _searchController.text;
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<AddressPickerBloc>().add(AddressPickerQueryChangedEvent(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AddressPickerBloc, AddressPickerState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure ||
          previous.resolvedAddress != current.resolvedAddress,
      listener: (context, state) {
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: AppTheme.error,
            ),
          );
        }

        if (state.resolvedAddress != null) {
          final currentAddress = context.read<ServicePublishBloc>().state.address;
          final merged = _mergeAddress(currentAddress, state.resolvedAddress!);
          if (merged != currentAddress) {
            _update(context, merged);
          }
        }
      },
      child: BlocBuilder<ServicePublishBloc, ServicePublishState>(
        builder: (context, publishState) {
          final address = publishState.address;

          return BlocBuilder<AddressPickerBloc, AddressPickerState>(
            builder: (context, pickerState) {
              final position = _resolveMapPosition(address, pickerState.position);
              final isLoadingLocation =
                  pickerState.status == AddressPickerStatus.loadingLocation;
              final isResolving =
                  pickerState.status == AddressPickerStatus.resolvingAddress;

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
                      'Selecciona tu ubicacion actual o busca la direccion. Tambien puedes tocar el mapa para ajustar el punto.',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _searchController,
                      label: 'Buscar direccion',
                      hint: 'Ej: Calle 10 # 20-30',
                      prefixIcon: Icons.search,
                    ),
                    if (pickerState.suggestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildSuggestions(pickerState),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: isLoadingLocation
                                ? null
                                : () {
                                    context
                                        .read<AddressPickerBloc>()
                                        .add(const AddressPickerLoadCurrentLocationEvent());
                                  },
                            icon: const Icon(Icons.my_location),
                            label: Text(
                              isLoadingLocation
                                  ? 'Ubicando...'
                                  : 'Usar mi ubicacion actual',
                            ),
                          ),
                        ),
                        if (isResolving)
                          const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MapAddressPicker(
                      initialPosition: position,
                      position: position,
                      onPositionChanged: (pos) {
                        _update(
                          context,
                          address.copyWith(
                            latitude: pos.latitude,
                            longitude: pos.longitude,
                          ),
                        );
                        context.read<AddressPickerBloc>().add(
                              AddressPickerSelectPositionEvent(
                                GeoCoordinates(
                                  latitude: pos.latitude,
                                  longitude: pos.longitude,
                                ),
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: TextEditingController(text: address.addressLine1)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: address.addressLine1.length),
                        ),
                      label: 'Direccion (Calle / Carrera)',
                      hint: 'Ej: Calle 10 # 20-30',
                      onChanged: (v) =>
                          _update(context, address.copyWith(addressLine1: v)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: TextEditingController(text: address.neighborhood)
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: address.neighborhood?.length ?? 0),
                              ),
                            label: 'Barrio',
                            onChanged: (v) =>
                                _update(context, address.copyWith(neighborhood: v)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: TextEditingController(text: address.city)
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: address.city.length),
                              ),
                            label: 'Ciudad',
                            onChanged: (v) =>
                                _update(context, address.copyWith(city: v)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: TextEditingController(text: address.addressLine2)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: address.addressLine2?.length ?? 0),
                        ),
                      label: 'Apto / Interior / Referencia (Opcional)',
                      onChanged: (v) =>
                          _update(context, address.copyWith(addressLine2: v)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  LatLng? _resolveMapPosition(ServiceAddress address, GeoCoordinates? position) {
    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    }

    if (address.latitude != null && address.longitude != null) {
      return LatLng(address.latitude!, address.longitude!);
    }

    return null;
  }

  Widget _buildSuggestions(AddressPickerState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.suggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final suggestion = state.suggestions[index];
          return ListTile(
            title: Text(suggestion.label),
            onTap: () {
              _searchController.removeListener(_onSearchChanged);
              _searchController.text = suggestion.label;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
              _searchController.addListener(_onSearchChanged);
              context
                  .read<AddressPickerBloc>()
                  .add(AddressPickerSelectSuggestionEvent(suggestion));
            },
          );
        },
      ),
    );
  }

  ServiceAddress _mergeAddress(ServiceAddress current, ServiceAddress resolved) {
    return current.copyWith(
      addressLine1:
          resolved.addressLine1.isNotEmpty ? resolved.addressLine1 : current.addressLine1,
      addressLine2: resolved.addressLine2 ?? current.addressLine2,
      city: resolved.city.isNotEmpty ? resolved.city : current.city,
      neighborhood: resolved.neighborhood ?? current.neighborhood,
      latitude: resolved.latitude ?? current.latitude,
      longitude: resolved.longitude ?? current.longitude,
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
