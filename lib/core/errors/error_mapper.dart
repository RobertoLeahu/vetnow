import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';
import 'app_error.dart';
import 'app_error_code.dart';

AppError mapError(Object error) {
  if (error is AppError) return error;

  if (error is StateError &&
      error.message.contains('Confirma la cita en la agenda')) {
    return const AppError(AppErrorCode.appointmentNotConfirmedForNotes);
  }

  if (error is RegisterException) {
    return switch (error.failure) {
      RegisterFailure.emailAlreadyExists => const AppError(
        AppErrorCode.authEmailAlreadyExists,
      ),
      RegisterFailure.emailExistsWrongPassword => const AppError(
        AppErrorCode.authWrongPassword,
      ),
    };
  }

  if (error is TimeoutException) {
    final lowerMessage = (error.message ?? '').toLowerCase();
    if (lowerMessage.contains('location') || lowerMessage.contains('ubic')) {
      return AppError(
        AppErrorCode.locationTimeout,
        debugMessage: error.toString(),
      );
    }
    return AppError(AppErrorCode.timeout, debugMessage: error.toString());
  }

  if (error is SocketException) {
    return AppError(AppErrorCode.network, debugMessage: error.message);
  }

  if (error is AuthException) {
    final code = (error.code ?? '').toLowerCase();
    final message = error.message.toLowerCase();

    if (code == 'user_already_exists' ||
        code == 'user_already_exist' ||
        message.contains('already registered')) {
      return AppError(
        AppErrorCode.authEmailAlreadyExists,
        debugMessage: error.toString(),
      );
    }

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return AppError(
        AppErrorCode.authInvalidCredentials,
        debugMessage: error.toString(),
      );
    }

    if (code == 'session_not_found' || code == 'session_expired') {
      return AppError(
        AppErrorCode.authSessionExpired,
        debugMessage: error.toString(),
      );
    }

    return AppError(AppErrorCode.server, debugMessage: error.toString());
  }

  if (error is PostgrestException) {
    final code = error.code ?? '';
    if (code == 'PGRST301' || code == 'PGRST302') {
      return AppError(AppErrorCode.authSessionExpired, debugMessage: '$error');
    }
    if (error.code == '404') {
      return AppError(AppErrorCode.notFound, debugMessage: '$error');
    }
    return AppError(AppErrorCode.server, debugMessage: '$error');
  }

  final raw = error.toString().toLowerCase();
  if (raw.contains('timeout') &&
      (raw.contains('location') || raw.contains('position'))) {
    return AppError(AppErrorCode.locationTimeout, debugMessage: '$error');
  }
  if (raw.contains('location service') ||
      raw.contains('location disabled') ||
      raw.contains('geolocator')) {
    return AppError(AppErrorCode.locationUnavailable, debugMessage: '$error');
  }

  return AppError(AppErrorCode.unknown, debugMessage: '$error');
}

void logAppError(Object error, [StackTrace? stackTrace]) {
  if (!kDebugMode) return;
  final mapped = mapError(error);
  debugPrint('[VetNow][AppError] code=${mapped.code} error=$error');
  if (stackTrace != null) {
    debugPrint('[VetNow][AppError] stackTrace=$stackTrace');
  }
}
