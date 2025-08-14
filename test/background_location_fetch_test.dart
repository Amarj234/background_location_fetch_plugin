import 'package:flutter_test/flutter_test.dart';
import 'package:background_location_fetch/background_location_fetch.dart';
import 'package:background_location_fetch/background_location_fetch_platform_interface.dart';
import 'package:background_location_fetch/background_location_fetch_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBackgroundLocationFetchPlatform
    with MockPlatformInterfaceMixin
    implements BackgroundLocationFetchPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BackgroundLocationFetchPlatform initialPlatform = BackgroundLocationFetchPlatform.instance;

  test('$MethodChannelBackgroundLocationFetch is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBackgroundLocationFetch>());
  });

  test('getPlatformVersion', () async {
    BackgroundLocationFetch backgroundLocationFetchPlugin = BackgroundLocationFetch();
    MockBackgroundLocationFetchPlatform fakePlatform = MockBackgroundLocationFetchPlatform();
    BackgroundLocationFetchPlatform.instance = fakePlatform;

    expect(await backgroundLocationFetchPlugin.getPlatformVersion(), '42');
  });
}
