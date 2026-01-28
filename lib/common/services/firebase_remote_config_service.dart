import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigService {
  final _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> setupRemoteConfig() => Future.wait([
    _remoteConfig.setDefaults(<String, dynamic>{
      'latest_version': '1.0.0',
      'required_version': '1.0.0',
    }),

    _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 60),
        minimumFetchInterval: Duration.zero,
      ),
    ),
    _remoteConfig.fetchAndActivate(),
  ]);

  String? getLatestVersion() {
    if (_remoteConfig.lastFetchStatus != RemoteConfigFetchStatus.failure &&
        _remoteConfig.lastFetchStatus != RemoteConfigFetchStatus.noFetchYet) {
      return _remoteConfig.getString('latest_version');
    }

    return null;
  }

  String? getRequiredVersion() {
    if (_remoteConfig.lastFetchStatus != RemoteConfigFetchStatus.failure &&
        _remoteConfig.lastFetchStatus != RemoteConfigFetchStatus.noFetchYet) {
      return _remoteConfig.getString('required_version');
    }

    return null;
  }
}
