import 'package:flutter/material.dart';

FlavorConfig appFlavor = FlavorConfig();

class FlavorConfig {
  FlavorConfig({
    this.appTitle = 'Tefter',
    this.apiUrl = 'https://api.tefter.com',
    this.theme,
    this.imageLocation,
  });

  final String appTitle;
  final String apiUrl;
  final ThemeData? theme;
  final String? imageLocation;
}
