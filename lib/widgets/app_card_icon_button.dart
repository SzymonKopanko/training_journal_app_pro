import 'package:flutter/material.dart';

class AppCardIconButton extends StatelessWidget {
  const AppCardIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = destructive ? scheme.errorContainer : scheme.primaryContainer;
    final foreground = destructive ? scheme.onErrorContainer : scheme.onPrimaryContainer;

    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: const Size(44, 40),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon),
      ),
    );
  }
}
