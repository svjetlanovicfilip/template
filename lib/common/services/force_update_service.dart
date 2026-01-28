import 'dart:math';

import 'package:package_info_plus/package_info_plus.dart';

import 'firebase_remote_config_service.dart';

class ForceUpdateService {
  ForceUpdateService(this.remoteConfigService);

  final FirebaseRemoteConfigService remoteConfigService;

  Future<bool> isUpdateRequired() =>
      _isNewer(remoteConfigService.getRequiredVersion());

  Future<bool> isUpdateAvailable() =>
      _isNewer(remoteConfigService.getLatestVersion());

  Future<bool> _isNewer(String? version) async {
    if (version == null) {
      return false;
    }

    final currentVersion =
        (await PackageInfo.fromPlatform()).version
            .split('.')
            .map(int.parse)
            .toList();

    final enforcedVersion = version.split('.').map(int.parse).toList();

    for (
      var i = 0;
      i < min(currentVersion.length, enforcedVersion.length);
      i++
    ) {
      if (enforcedVersion[i] > currentVersion[i]) {
        return true;
      } else if (enforcedVersion[i] < currentVersion[i]) {
        return false;
      }
    }

    return false;
  }
}
