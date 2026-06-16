import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../overlay/overlay.dart';

extension GetExtension on GetInterface {
  void loading({bool barrierDismissible = false}) {
    AppOverlay.dialog.showLoading(
      barrierDismissible: barrierDismissible,
      customLoading: PopScope(
        canPop: barrierDismissible,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFAC331)),
          ),
        ),
      ),
    );
  }

  Future<void> dismiss() async {
    AppOverlay.dialog.hideLoading();
  }
}
