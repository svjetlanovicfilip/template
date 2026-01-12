import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  NavigatorState get _router => Navigator.of(this);

  void pushReplacementNamed(String name, {Object? arguments}) {
    _router.pushReplacementNamed(name, arguments: arguments);
  }

  void pushNamed(String name, {Object? arguments}) {
    _router.pushNamed(name, arguments: arguments);
  }

  void pop({Object? result}) {
    _router.pop(result);
  }
}
