import 'package:flutter/material.dart';
import 'package:domora/core/theme/app_theme.dart';

class ServiceCounterInput extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final IconData icon;

  const ServiceCounterInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.remove,
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.add,
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed == null
          ? AppTheme.border.withOpacity(0.3)
          : AppTheme.primarySoft,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: onPressed == null ? Colors.grey : AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
