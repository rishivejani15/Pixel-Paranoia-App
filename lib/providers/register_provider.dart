import 'package:flutter/material.dart';

class RegisterProvider with ChangeNotifier {
  bool processing = false;
  String? lastScannedQr;

  void setProcessing(bool val) {
    processing = val;
    notifyListeners();
  }

  void setLastScannedQr(String? qr) {
    lastScannedQr = qr;
    notifyListeners();
  }

  void resetState() {
    processing = false;
    lastScannedQr = null;
    notifyListeners();
  }
}
