import 'package:flutter/material.dart';
import 'package:domora/core/utils/constants.dart';

/// Selector visual entre rol de cliente y rol de proveedor.
/// Devuelve [AppConstants.roleClient] o [AppConstants.roleProvider].
class RoleSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const RoleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Quiero registrarme como',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                icon: Icons.home_work_outlined,
                title: 'Cliente',
                subtitle: 'Necesito un servicio',
                selected: selected == AppConstants.roleClient,
                onTap: () => onChanged(AppConstants.roleClient),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleCard(
                icon: Icons.handyman_outlined,
                title: 'Proveedor',
                subtitle: 'Ofrezco servicios',
                selected: selected == AppConstants.roleProvider,
                onTap: () => onChanged(AppConstants.roleProvider),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : theme.dividerColor;
    final bg = selected
        ? theme.colorScheme.primary.withOpacity(0.07)
        : theme.colorScheme.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
