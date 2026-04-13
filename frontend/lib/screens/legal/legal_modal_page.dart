import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class LegalModalPage extends StatelessWidget {
  const LegalModalPage({super.key, required this.title, required this.body});

  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,

      // Figma-like top bar (back arrow + centered purple title)
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        surfaceTintColor: MuudColors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_ios_new, color: MuudColors.purple),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: MuudColors.purple,
            fontWeight: FontWeight.w800,
            fontSize: 30, // close to Figma
            height: 1.1,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF2B2B2B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
