import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppScreenPadding extends StatelessWidget {
  const AppScreenPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: AppSpacing.screen, child: child);
  }
}
