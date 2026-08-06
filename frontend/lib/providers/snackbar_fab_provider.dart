import 'package:flutter/material.dart';

class SnackbarFabProvider extends ChangeNotifier {
  bool _showHomeFab = true;
  bool _compactNavigationBar = false;
  int _snackbarNumber = 0;

  bool get showHomeFab => _showHomeFab;
  bool get compactNavigationBar => _compactNavigationBar;

  void setNavigationBarCompact(bool value) {
    if (_compactNavigationBar == value) return;
    _compactNavigationBar = value;
    notifyListeners();
  }

  void showSnackBar(BuildContext context, SnackBar snackBar) {
    final currentSnackbarNumber = ++_snackbarNumber;
    _showHomeFab = false;
    notifyListeners();
    final controller = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    controller.showSnackBar(snackBar).closed.then((_) {
      if (currentSnackbarNumber != _snackbarNumber) {
        return;
      }
      _showHomeFab = true;
      notifyListeners();
    });
  }

  void hideCurrentSnackBar(BuildContext context) {
    _snackbarNumber++;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _showHomeFab = true;
    notifyListeners();
  }

  void clearSnackBars(BuildContext context) {
    _snackbarNumber++;
    ScaffoldMessenger.of(context).clearSnackBars();
    _showHomeFab = true;
    notifyListeners();
  }
}
