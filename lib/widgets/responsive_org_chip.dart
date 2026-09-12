import 'package:flutter/material.dart';

import '../theme.dart';

/// Compact organization/filter chip that remains safe on narrow layouts and
/// with large accessibility text scales.
class ResponsiveOrgChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final IconData? trailingIcon;
  final Widget? trailing;

  const ResponsiveOrgChip({
    super.key,
    required this.icon,
    required this.label,
    this.trailingIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 32,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: EmberColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmberColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: EmberColors.textMid),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: EmberColors.textHigh,
                fontSize: 12,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 2),
            Icon(trailingIcon, size: 14, color: EmberColors.textMid),
          ],
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing!,
          ],
        ],
      ),
    );
  }
}
