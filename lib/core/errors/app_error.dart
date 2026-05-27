import 'app_error_code.dart';

class AppError {
  const AppError(this.code, {this.debugMessage});

  final AppErrorCode code;
  final String? debugMessage;
}
