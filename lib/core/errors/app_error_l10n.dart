import '../../l10n/app_localizations.dart';
import 'app_error.dart';
import 'app_error_code.dart';

extension AppErrorL10n on AppError {
  String message(AppLocalizations l10n) => switch (code) {
        AppErrorCode.locationTimeout => l10n.errorLocationTimeout,
        AppErrorCode.locationUnavailable => l10n.errorLocationUnavailable,
        AppErrorCode.locationPermissionDenied =>
          l10n.errorLocationPermissionDenied,
        AppErrorCode.network => l10n.errorNetwork,
        AppErrorCode.timeout => l10n.errorTimeout,
        AppErrorCode.authEmailAlreadyExists => l10n.registerEmailAlreadyExists,
        AppErrorCode.authWrongPassword => l10n.registerEmailExistsWrongPassword,
        AppErrorCode.authInvalidCredentials => l10n.loginErrorInvalidCredentials,
        AppErrorCode.authSessionExpired => l10n.errorSessionExpired,
        AppErrorCode.server => l10n.errorServer,
        AppErrorCode.notFound => l10n.errorNotFound,
        AppErrorCode.validation => l10n.errorValidation,
        AppErrorCode.unknown => l10n.errorGeneric,
      };
}
