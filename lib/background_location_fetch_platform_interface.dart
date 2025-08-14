import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'background_location_fetch.dart';

abstract class BackgroundLocationFetchPlatform extends PlatformInterface {
  /// Constructs a BackgroundLocationFetchPlatform.
  BackgroundLocationFetchPlatform() : super(token: _token);

  static final Object _token = Object();

  static BackgroundLocationFetchPlatform _instance = BackgroundLocationFetch();

  /// The default instance of [BackgroundLocationFetchPlatform] to use.
  ///
  /// Defaults to [MethodChannelBackgroundLocationFetch].
  static BackgroundLocationFetchPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BackgroundLocationFetchPlatform] when
  /// they register themselves.
  static set instance(BackgroundLocationFetchPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
