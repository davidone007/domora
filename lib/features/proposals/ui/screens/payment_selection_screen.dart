import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/custom_text_field.dart';
import '../bloc/payment_bloc.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final String bookingId;
  final double amount;

  const PaymentSelectionScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String _selectedMethod = 'card'; // 'card' or 'cash'
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state.status == PaymentStatus.success) {
          if (!context.mounted) return;
          context.go('/payment-success');
        }
        if (state.status == PaymentStatus.error && state.errorMessage != null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppTheme.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Completar Pago'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total a pagar:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currencyFormat.format(widget.amount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Selecciona un método de pago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Opciones
              _PaymentOptionTile(
                title: 'Tarjeta de Crédito / Débito',
                icon: Icons.credit_card,
                isSelected: _selectedMethod == 'card',
                onTap: () => setState(() => _selectedMethod = 'card'),
              ),
              const SizedBox(height: 12),
              _PaymentOptionTile(
                title: 'Efectivo',
                icon: Icons.payments_outlined,
                isSelected: _selectedMethod == 'cash',
                onTap: () => setState(() => _selectedMethod = 'cash'),
              ),

              const SizedBox(height: 32),

              // Formulario Mock Tarjeta
              if (_selectedMethod == 'card') ...[
                const Text(
                  'Datos de la tarjeta',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Número de Tarjeta',
                  controller: _cardNumberController,
                  hint: '0000 0000 0000 0000',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.credit_card,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Vencimiento',
                        controller: _expiryController,
                        hint: 'MM/AA',
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'CVV',
                        controller: _cvvController,
                        hint: '123',
                        keyboardType: TextInputType.number,
                        isPassword: true,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Pagarás en efectivo al finalizar el servicio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  return CustomButton(
                    label: _selectedMethod == 'card' ? 'Pagar Ahora' : 'Confirmar Contratación',
                    isLoading: state.status == PaymentStatus.loading,
                    onPressed: () {
                      context.read<PaymentBloc>().add(
                            ProcessPaymentRequestedEvent(
                              bookingId: widget.bookingId,
                              amount: widget.amount,
                              method: _selectedMethod,
                              transactionId: _selectedMethod == 'card' ? 'MOCK_TX_${DateTime.now().millisecondsSinceEpoch}' : null,
                            ),
                          );
                    },
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

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primarySoft.withOpacity(0.3) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
