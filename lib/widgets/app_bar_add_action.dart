import 'package:flutter/material.dart';

class AppBarAddAction extends StatelessWidget {
  const AppBarAddAction({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      tooltip: tooltip,
    );
  }
}
