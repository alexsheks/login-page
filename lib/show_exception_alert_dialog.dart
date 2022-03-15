import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'show_alert_dialog.dart';

Future<void> showExceptionAlertDialog(
  BuildContext context, {
  required String title,
  required Exception exception,
}) =>
    showAlertDialog(
      context,
      title: title,
      content: _message(exception),
      defaultActionText: 'OK',
    );

String? _message(Exception? exception) {
  if (exception is FirebaseException) {
    switch (exception.code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "Email уже используется. Перейдите к странице авторизации.";
        break;
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Неправильная комбинация email/пароль.";
        break;
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "Не найден пользователь с таким email.";
        break;
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "Пользователь недоступен.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Слишком много запросов авторизации для этого аккаунта.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
      case "operation-not-allowed":
        return "Ошибка сервера, пожалуйста, попробуйте позже.";
        break;
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Некорректно введен email адрес .";
        break;
      default:
        return "Ошибка авторизации. Пожалуйста, попробуйте снова.";
        break;
    }
  }
  return exception.toString();
}
