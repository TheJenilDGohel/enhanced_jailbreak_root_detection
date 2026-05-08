import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enhanced_jailbreak_root_detection/enhanced_jailbreak_root_detection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EnhancedJailbreakRootDetection - isNotTrust', () {
    late EnhancedJailbreakRootDetection detection;
    final List<MethodCall> log = <MethodCall>[];

    // Default mock responses
    late bool mockJailBroken;
    late bool mockRealDevice;
    late bool mockExternalStorage;
    late bool throwException;

    setUp(() {
      detection = EnhancedJailbreakRootDetection.instance;
      log.clear();
      mockJailBroken = false;
      mockRealDevice = true;
      mockExternalStorage = false;
      throwException = false;
      detection.debugIsAndroidOverride = false; // By default, act as non-Android

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(detection.methodChannel, (MethodCall methodCall) async {
        log.add(methodCall);

        if (throwException) {
          throw PlatformException(code: 'ERROR', message: 'Test exception');
        }

        switch (methodCall.method) {
          case 'isJailBroken':
            return mockJailBroken;
          case 'isRealDevice':
            return mockRealDevice;
          case 'isOnExternalStorage':
            return mockExternalStorage;
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(detection.methodChannel, null);
      detection.debugIsAndroidOverride = null;
    });

    test('returns false when device is trusted (not jailbroken, real device, not android)', () async {
      final result = await detection.isNotTrust;
      expect(result, isFalse);
    });

    test('returns true when device is jailbroken', () async {
      mockJailBroken = true;
      final result = await detection.isNotTrust;
      expect(result, isTrue);
    });

    test('returns true when device is not a real device', () async {
      mockRealDevice = false;
      final result = await detection.isNotTrust;
      expect(result, isTrue);
    });

    test('returns true when an exception is thrown', () async {
      throwException = true;
      final result = await detection.isNotTrust;
      expect(result, isTrue);
    });

    group('Platform.isAndroid branching', () {
      setUp(() {
        detection.debugIsAndroidOverride = true;
      });

      test('returns false when device is trusted (not jailbroken, real device, not on external storage)', () async {
        final result = await detection.isNotTrust;
        expect(result, isFalse);
      });

      test('returns true when device is on external storage (Android specific)', () async {
        mockExternalStorage = true;
        final result = await detection.isNotTrust;
        expect(result, isTrue);
      });
    });
  });
}
