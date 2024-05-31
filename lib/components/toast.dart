import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

void showErrorToast(BuildContext context, {required String message}) {
  DelightToastBar(
    autoDismiss: true,
    position: DelightSnackbarPosition.top,
    builder: (context) => ToastCard(
      color: const Color.fromARGB(240, 255, 207, 207),
      leading: const Icon(
        Icons.error,
        color: Colors.red,
        size: 28,
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.red,
        ),
      ),
    ),
  ).show(context);
}

void showSuccessToast(BuildContext context, {required String message}) {
  DelightToastBar(
    autoDismiss: true,
    position: DelightSnackbarPosition.bottom,
    builder: (context) => ToastCard(
      leading: const Icon(
        Icons.check,
        color: Colors.green,
        size: 28,
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.green,
        ),
      ),
    ),
  ).show(context);
}
