import 'package:flutter/material.dart';

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

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: kPurple,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (trailingText != null)
          GestureDetector(
            onTap: onTapTrailing,
            child: Text(
              trailingText!,
              style: const TextStyle(
                color: kPurple,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
