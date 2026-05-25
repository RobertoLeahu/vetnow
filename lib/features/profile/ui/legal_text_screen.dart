import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class LegalTextScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalTextScreen({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SelectableText(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
