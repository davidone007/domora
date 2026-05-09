import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:domora/core/utils/validators.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import 'package:domora/core/widgets/loading_overlay.dart';
import 'package:domora/core/widgets/simple_form.dart';

import '../../domain/entities/cleaning_service_detail.dart';
import '../../domain/entities/cleaning_service_request.dart';
import '../../domain/entities/service_address.dart';
import '../bloc/service_publish_bloc.dart';
import '../widgets/map_address_picker.dart';
import '../widgets/service_counter_input.dart';

class PublishServiceScreen extends StatefulWidget {
  final String userId;

  const PublishServiceScreen({super.key, required this.userId});

  @override
  State<PublishServiceScreen> createState() => _PublishServiceScreenState();
}

class _PublishServiceScreenState extends State<PublishServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Campos generales
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  // Detalles de limpieza
  int _bathrooms = 1;
  int _kitchens = 1;
  int _bedrooms = 1;
  int _livingRooms = 1;
  bool _includesBalcony = false;
  bool _hasOwnSupplies = false;
  final _suppliesNotesCtrl = TextEditingController();

  // Dirección
  final _addressLine1Ctrl = TextEditingController();
  final _addressLine2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Cali');
  final _neighborhoodCtrl = TextEditingController();
  LatLng _selectedLocation = const LatLng(3.4516, -76.5320);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _suppliesNotesCtrl.dispose();
    _addressLine1Ctrl.dispose();
    _addressLine2Ctrl.dispose();
    _cityCtrl.dispose();
    _neighborhoodCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = CleaningServiceRequest(
      clientId: widget.userId,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
      preferredDate: _selectedDate,
      preferredTimeStart: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
      address: ServiceAddress(
        addressLine1: _addressLine1Ctrl.text.trim(),
        addressLine2: _addressLine2Ctrl.text.trim().isEmpty ? null : _addressLine2Ctrl.text.trim(),
        city: _cityCtrl.text.trim(),
        neighborhood: _neighborhoodCtrl.text.trim().isEmpty ? null : _neighborhoodCtrl.text.trim(),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      ),
      details: CleaningServiceDetail(
        bathrooms: _bathrooms,
        kitchens: _kitchens,
        bedrooms: _bedrooms,
        livingRooms: _livingRooms,
        includesBalcony: _includesBalcony,
        hasOwnSupplies: _hasOwnSupplies,
        suppliesNotes: _suppliesNotesCtrl.text.trim().isEmpty ? null : _suppliesNotesCtrl.text.trim(),
      ),
    );

    context.read<ServicePublishBloc>().add(ServicePublishSubmitEvent(request));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ServicePublishBloc, ServicePublishState>(
      listener: (context, state) {
        if (state is ServicePublishSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Servicio publicado con éxito')),
          );
          context.pop(); // Regresa al home (o lista de servicios)
        } else if (state is ServicePublishError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<ServicePublishBloc, ServicePublishState>(
        builder: (context, state) {
          final isLoading = state is ServicePublishLoading;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Publicando servicio...',
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Publicar Limpieza'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SimpleForm(
                  formKey: _formKey,
                  children: [
                    Text('Información General', style: theme.textTheme.titleLarge),
                    CustomTextField(
                      controller: _titleCtrl,
                      label: 'Título de la solicitud',
                      hint: 'Ej: Limpieza profunda apto 3 hab',
                      validator: (v) => Validators.required(v, fieldName: 'El título'),
                    ),
                    CustomTextField(
                      controller: _descriptionCtrl,
                      label: 'Descripción (opcional)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Text('¿Cuándo lo necesitas?', style: theme.textTheme.titleMedium),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                            onPressed: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(_selectedTime.format(context)),
                            onPressed: _pickTime,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 40),
                    Text('Detalles del lugar', style: theme.textTheme.titleLarge),
                    ServiceCounterInput(
                      label: 'Habitaciones',
                      icon: Icons.bed_outlined,
                      value: _bedrooms,
                      onChanged: (v) => setState(() => _bedrooms = v),
                    ),
                    ServiceCounterInput(
                      label: 'Baños',
                      icon: Icons.bathtub_outlined,
                      value: _bathrooms,
                      onChanged: (v) => setState(() => _bathrooms = v),
                    ),
                    ServiceCounterInput(
                      label: 'Salas / Comedores',
                      icon: Icons.weekend_outlined,
                      value: _livingRooms,
                      onChanged: (v) => setState(() => _livingRooms = v),
                    ),
                    ServiceCounterInput(
                      label: 'Cocinas',
                      icon: Icons.kitchen_outlined,
                      value: _kitchens,
                      onChanged: (v) => setState(() => _kitchens = v),
                    ),

                    CheckboxListTile(
                      title: const Text('Incluye balcón / terraza'),
                      value: _includesBalcony,
                      onChanged: (v) => setState(() => _includesBalcony = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    const Divider(height: 40),
                    Text('Insumos', style: theme.textTheme.titleLarge),
                    SwitchListTile(
                      title: const Text('Tengo mis propios implementos'),
                      subtitle: const Text('Jabones, traperos, aspiradora, etc.'),
                      value: _hasOwnSupplies,
                      onChanged: (v) => setState(() => _hasOwnSupplies = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (!_hasOwnSupplies)
                      CustomTextField(
                        controller: _suppliesNotesCtrl,
                        label: 'Notas sobre insumos',
                        hint: '¿Qué le hace falta al aseador?',
                        maxLines: 2,
                      ),

                    const Divider(height: 40),
                    Text('Ubicación', style: theme.textTheme.titleLarge),
                    const Text('Selecciona el punto exacto en el mapa:'),
                    const SizedBox(height: 8),
                    MapAddressPicker(
                      onPositionChanged: (pos) => setState(() => _selectedLocation = pos),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressLine1Ctrl,
                      label: 'Dirección (Calle/Carrera)',
                      hint: 'Ej: Calle 10 # 20-30',
                      validator: (v) => Validators.required(v, fieldName: 'La dirección'),
                    ),
                    CustomTextField(
                      controller: _neighborhoodCtrl,
                      label: 'Barrio (opcional)',
                    ),
                    CustomTextField(
                      controller: _addressLine2Ctrl,
                      label: 'Apto / Interior / Torre (opcional)',
                    ),

                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Publicar solicitud',
                      onPressed: _submit,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
