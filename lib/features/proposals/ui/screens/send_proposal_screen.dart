import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import '../../domain/entities/proposal.dart';
import '../bloc/proposal_send_bloc.dart';

class SendProposalScreen extends StatefulWidget {
  final String serviceId;

  const SendProposalScreen({super.key, required this.serviceId});

  @override
  State<SendProposalScreen> createState() => _SendProposalScreenState();
}

class _SendProposalScreenState extends State<SendProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _hoursController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProposalSendBloc>().add(
          CheckProposalStatusEvent(
            serviceId: widget.serviceId,
          ),
        );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _hoursController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Ya no extraemos el ID aquí. El BLoC validará la identidad internamente.
    // Usamos un ID vacío temporal que el BLoC ignorará al inyectar el real de la sesión.
    final proposal = Proposal(
      serviceId: widget.serviceId,
      providerId: '', 
      price: double.parse(_priceController.text),
      estimatedHours: _hoursController.text.isNotEmpty
          ? double.parse(_hoursController.text)
          : null,
      message: _messageController.text,
    );

    context.read<ProposalSendBloc>().add(SubmitProposalEvent(proposal));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Enviar Cotización'),
      ),
      body: BlocConsumer<ProposalSendBloc, ProposalSendState>(
        listener: (context, state) {
          if (state.status == ProposalSendStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cotización enviada con éxito')),
            );
            Navigator.pop(context, true);
          }
          if (state.status == ProposalSendStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error al enviar cotización'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ProposalSendStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProposalSendStatus.alreadyProposed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 64, color: AppTheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Ya has enviado una propuesta para este servicio',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Volver',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles de tu oferta',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingresa el valor total por el cual realizarás este servicio.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Precio total (COP)',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    hint: 'Ej: 50000',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El precio es obligatorio';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Ingresa un precio válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Tiempo estimado (horas)',
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.timer_outlined,
                    hint: 'Ej: 4',
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Mensaje adicional',
                    controller: _messageController,
                    maxLines: 4,
                    hint: 'Cuéntale al cliente por qué eres la mejor opción...',
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    label: 'Enviar Cotización',
                    onPressed: state.status == ProposalSendStatus.submitting
                        ? null
                        : _submit,
                    isLoading: state.status == ProposalSendStatus.submitting,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
