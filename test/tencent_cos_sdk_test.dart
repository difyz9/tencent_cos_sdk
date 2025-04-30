import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_cos_sdk/tencent_cos_sdk.dart';
import 'package:tencent_cos_sdk/tencent_cos_sdk_platform_interface.dart';
import 'package:tencent_cos_sdk/tencent_cos_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTencentCosSdkPlatform
    with MockPlatformInterfaceMixin
    implements TencentCosSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TencentCosSdkPlatform initialPlatform = TencentCosSdkPlatform.instance;

  test('$MethodChannelTencentCosSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTencentCosSdk>());
  });

  test('getPlatformVersion', () async {
    TencentCosSdk tencentCosSdkPlugin = TencentCosSdk();
    MockTencentCosSdkPlatform fakePlatform = MockTencentCosSdkPlatform();
    TencentCosSdkPlatform.instance = fakePlatform;

    expect(await tencentCosSdkPlugin.getPlatformVersion(), '42');
  });
}
