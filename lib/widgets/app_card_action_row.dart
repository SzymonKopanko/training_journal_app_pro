import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppCardActionRow extends StatelessWidget {
  const AppCardActionRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) AppSpacing.gapSm,
          children[i],
        ],
      ],
    );
  }
}
