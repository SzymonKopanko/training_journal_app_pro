import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Standardowy padding treści ekranu (formularze, ustawienia).
class AppScreenBody extends StatelessWidget {
  const AppScreenBody({
    super.key,
    required this.child,
    this.scrollable = false,
  });

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(
        padding: AppSpacing.screen,
        child: child,
      );
    }
    return Padding(
      padding: AppSpacing.screen,
      child: child,
    );
  }
}
