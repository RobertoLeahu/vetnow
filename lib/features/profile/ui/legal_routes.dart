import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../shared/legal/legal_texts.dart';
import 'legal_text_screen.dart';

class LegalPrivacyRoute extends ConsumerWidget {
  const LegalPrivacyRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final code = ref.watch(localeProvider).languageCode;
    return LegalTextScreen(
      title: l10n.privacyPolicyTitle,
      content: privacyPolicyForLocale(code),
    );
  }
}

class LegalTermsRoute extends ConsumerWidget {
  const LegalTermsRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final code = ref.watch(localeProvider).languageCode;
    return LegalTextScreen(
      title: l10n.termsOfServiceTitle,
      content: termsOfServiceForLocale(code),
    );
  }
}
