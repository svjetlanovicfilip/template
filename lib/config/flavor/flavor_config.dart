import 'package:flutter/material.dart';

class FlavorConfig {
  FlavorConfig({
    this.appTitle = 'Template',
    this.apiUrl = 'https://api.template.com',
    this.theme,
    this.imageLocation,
  });

  final String appTitle;
  final String apiUrl;
  final ThemeData? theme;
  final String? imageLocation;
}
