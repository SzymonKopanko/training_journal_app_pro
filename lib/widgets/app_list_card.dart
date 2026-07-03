import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppListCard extends StatelessWidget {
  const AppListCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? AppSpacing.card,
        child: child,
      ),
    );
  }
}
