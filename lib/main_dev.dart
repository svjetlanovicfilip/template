import './main.dart';

import 'config/flavor/flavor_config.dart';
import 'firebase_options_dev.dart';

void main() {
  appFlavor = FlavorConfig(appTitle: 'Tefter Dev');

  mainApp(DefaultFirebaseOptions.currentPlatform);
}
