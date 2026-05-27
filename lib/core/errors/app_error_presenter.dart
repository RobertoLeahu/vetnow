import 'package:flutter/material.dart';

import '../../l10n/l10n_ext.dart';
import '../../shared/widgets/app_error_snackbar.dart';
import 'app_error_l10n.dart';
import 'error_mapper.dart';

String appErrorMessage(BuildContext context, Object error) {
  return mapError(error).message(context.l10n);
}

void showAppError(BuildContext context, Object error, [StackTrace? stackTrace]) {
  logAppError(error, stackTrace);
  AppErrorSnackBar.show(context, appErrorMessage(context, error));
}
