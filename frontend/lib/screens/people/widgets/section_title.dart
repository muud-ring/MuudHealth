import 'package:flutter/material.dart';
import 'package:muud_health_app/theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTapTrailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailingText,
    this.onTapTrailing,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.purple,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (trailingText != null)
          InkWell(
            onTap: onTapTrailing,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                trailingText!,
                style: const TextStyle(
                  color: AppTheme.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
