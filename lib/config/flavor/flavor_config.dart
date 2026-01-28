import 'package:flutter/material.dart';

enum Flavor { dev, prod }

FlavorConfig appFlavor = FlavorConfig();

class FlavorConfig {
  FlavorConfig({
    this.appTitle = 'Tefter',
    this.apiUrl = 'https://api.tefter.com',
    this.theme,
    this.imageLocation,
    this.flavor = Flavor.prod,
  });

  final String appTitle;
  final String apiUrl;
  final ThemeData? theme;
  final String? imageLocation;
  final Flavor flavor;
}
