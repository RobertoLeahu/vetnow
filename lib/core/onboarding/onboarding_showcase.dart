import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../l10n/app_localizations.dart';

const onboardingScope = 'vetnow_onboarding';

typedef OnboardingShowcaseStart = void Function(int? index, GlobalKey key);

Showcase buildOnboardingShowcase({
  required GlobalKey showcaseKey,
  required Widget child,
  required String title,
  required String description,
  required AppLocalizations l10n,
  required BuildContext context,
  bool isLastStep = false,
  TooltipPosition? tooltipPosition,
  bool? enableAutoScroll,
}) {
  final theme = Theme.of(context);
  final primary = theme.colorScheme.primary;

  return Showcase(
    key: showcaseKey,
    title: title,
    description: description,
    tooltipPosition: tooltipPosition,
    enableAutoScroll: enableAutoScroll,
    tooltipBackgroundColor: primary,
    textColor: Colors.white,
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    descTextStyle: const TextStyle(
      fontSize: 14,
      height: 1.4,
      color: Colors.white,
    ),
    overlayOpacity: 0.85,
    targetBorderRadius: BorderRadius.circular(12),
    tooltipActionConfig: const TooltipActionConfig(
      position: TooltipActionPosition.inside,
      alignment: MainAxisAlignment.end,
      gapBetweenContentAndAction: 12,
    ),
    tooltipActions: [
      if (!isLastStep)
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: l10n.onboardingNext,
          backgroundColor: Colors.white,
          textStyle: TextStyle(color: primary, fontWeight: FontWeight.w600),
        )
      else
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: l10n.onboardingGotIt,
          backgroundColor: Colors.white,
          textStyle: TextStyle(color: primary, fontWeight: FontWeight.w600),
        ),
    ],
    child: child,
  );
}

void registerOnboardingShowcaseView({
  required VoidCallback onComplete,
  required String skipLabel,
  required GlobalKey lastStepKey,
  OnShowcaseCallback? onStart,
}) {
  ShowcaseView.register(
    scope: onboardingScope,
    enableAutoScroll: true,
    skipIfTargetNotPresent: true,
    overlayOpacity: 0.85,
    onStart: onStart,
    onFinish: onComplete,
    onDismiss: (_) => onComplete(),
    globalFloatingActionWidget: (_) => FloatingActionWidget(
      right: 16,
      top: 48,
      child: TextButton(
        onPressed: () => ShowcaseView.getNamed(onboardingScope).dismiss(),
        child: Text(
          skipLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    hideFloatingActionWidgetForShowcase: [lastStepKey],
    globalTooltipActionConfig: const TooltipActionConfig(
      position: TooltipActionPosition.inside,
      alignment: MainAxisAlignment.end,
    ),
  );
}

void addOnboardingStartListener(OnboardingShowcaseStart listener) {
  ShowcaseView.getNamed(onboardingScope).addOnStartCallback(listener);
}

void removeOnboardingStartListener(OnboardingShowcaseStart listener) {
  ShowcaseView.getNamed(onboardingScope).removeOnStartCallback(listener);
}

void unregisterOnboardingShowcaseView() {
  try {
    ShowcaseView.getNamed(onboardingScope).unregister();
  } catch (_) {
    // Scope was never registered.
  }
}

void startOwnerOnboarding(List<GlobalKey> keys) {
  ShowcaseView.getNamed(onboardingScope).startShowCase(keys);
}

void startClinicOnboarding(List<GlobalKey> keys) {
  ShowcaseView.getNamed(onboardingScope).startShowCase(keys);
}
