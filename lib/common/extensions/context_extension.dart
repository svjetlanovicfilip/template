import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  NavigatorState get _router => Navigator.of(this);

  void pushReplacementNamed(String name) {
    _router.pushReplacementNamed(name);
  }

  void pushNamed(String name) {
    _router.pushNamed(name);
  }

  void pop() {
    _router.pop();
  }
}
