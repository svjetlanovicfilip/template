import 'config/flavor/flavor_config.dart';
import 'firebase_options_prod.dart';
import 'main.dart';

void main() {
  appFlavor = FlavorConfig();

  mainApp(DefaultFirebaseOptions.currentPlatform);
}
