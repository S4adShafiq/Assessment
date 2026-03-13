import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:myapp/main.dart';

void main() {
  testGoldens('Welcome Screen Golden', (tester) async {
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [
        Device.phone,
        Device.iphone11,
      ])
      ..addScenario(
        widget: const ProviderScope(child: MyApp()),
        name: 'default',
      );

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'welcome_screen');
  });
}
