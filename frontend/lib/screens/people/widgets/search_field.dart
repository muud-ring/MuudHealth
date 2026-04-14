import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PeopleSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const PeopleSearchField({super.key, required this.hint, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: MuudColors.purple, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: MuudColors.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
