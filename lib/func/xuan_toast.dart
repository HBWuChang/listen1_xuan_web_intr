import 'package:flutter/material.dart';
import 'package:get/get.dart';

void _showToast(
  String? title,
  String? message, {
  Color? backgroundColor,
  Color? colorText,
  SnackPosition? snackPosition,
  Duration? duration,
}) {
  try {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        title ?? '',
        message ?? '',
        backgroundColor: backgroundColor,
        colorText: colorText,
        snackPosition: snackPosition ?? SnackPosition.BOTTOM,
        duration: duration ?? const Duration(seconds: 3),
      );
    });
  } catch (e) {
    debugPrint('Error showing toast: $e');
  }
}

void showErrorToast({String? title, String? message}) {
  _showToast(title, message, backgroundColor: Colors.redAccent);
}

void showSuccessToast({String? title, String? message}) {
  _showToast(title, message, backgroundColor: Colors.green);
}
