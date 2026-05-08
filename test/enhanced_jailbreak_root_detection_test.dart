import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enhanced_jailbreak_root_detection/enhanced_jailbreak_root_detection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JailbreakIssue', () {
    test('fromString returns correct enum values', () {
      expect(JailbreakIssue.fromString("jailbreak"), JailbreakIssue.jailbreak);
      expect(JailbreakIssue.fromString("notRealDevice"), JailbreakIssue.notRealDevice);
      expect(JailbreakIssue.fromString("proxied"), JailbreakIssue.proxied);
      expect(JailbreakIssue.fromString("debugged"), JailbreakIssue.debugged);
      expect(JailbreakIssue.fromString("devMode"), JailbreakIssue.devMode);
      expect(JailbreakIssue.fromString("reverseEngineered"), JailbreakIssue.reverseEngineered);
      expect(JailbreakIssue.fromString("fridaFound"), JailbreakIssue.fridaFound);
      expect(JailbreakIssue.fromString("cydiaFound"), JailbreakIssue.cydiaFound);
      expect(JailbreakIssue.fromString("tampered"), JailbreakIssue.tampered);
      expect(JailbreakIssue.fromString("onExternalStorage"), JailbreakIssue.onExternalStorage);

      // Unknown values should return unknown
      expect(JailbreakIssue.fromString("unknown_value"), JailbreakIssue.unknown);
      expect(JailbreakIssue.fromString(""), JailbreakIssue.unknown);
    });
  });

  group('EnhancedJailbreakRootDetection', () {
    final EnhancedJailbreakRootDetection detection = EnhancedJailbreakRootDetection.instance;
    final List<MethodCall> log = <MethodCall>[];
    final Map<String, dynamic> methodChannelReturns = {};
    bool throwException = false;

    setUp(() {
      log.clear();
      methodChannelReturns.clear();
      throwException = false;
      detection.debugIsAndroidOverride = null;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(detection.methodChannel, (MethodCall methodCall) async {
        log.add(methodCall);
        
        if (throwException) {
          throw PlatformException(code: 'ERROR', message: 'Test exception');
        }

        return methodChannelReturns[methodCall.method];
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(detection.methodChannel, null);
      detection.debugIsAndroidOverride = null;
    });

    group('checkForIssues', () {
      test('returns mapped issues when method channel returns a valid list', () async {
        methodChannelReturns['checkForIssues'] = ["jailbreak", "proxied", "unknown_issue"];

        final issues = await detection.checkForIssues;

        expect(log, <Matcher>[isMethodCall('checkForIssues', arguments: null)]);
        expect(issues, [
          JailbreakIssue.jailbreak,
          JailbreakIssue.proxied,
          JailbreakIssue.unknown
        ]);
      });

      test('returns an empty list when method channel returns null', () async {
        methodChannelReturns['checkForIssues'] = null;

        final issues = await detection.checkForIssues;

        expect(log, <Matcher>[isMethodCall('checkForIssues', arguments: null)]);
        expect(issues, []);
      });

      test('handles null elements within the list', () async {
        methodChannelReturns['checkForIssues'] = ['jailbreak', null, 'debugged'];

        final issues = await detection.checkForIssues;

        expect(issues, [
          JailbreakIssue.jailbreak,
          JailbreakIssue.unknown,
          JailbreakIssue.debugged
        ]);
        expect(log, hasLength(1));
      });

      test('handles empty list from method channel', () async {
        methodChannelReturns['checkForIssues'] = <dynamic>[];

        final issues = await detection.checkForIssues;

        expect(issues, []);
        expect(log, hasLength(1));
      });
    });

    test('isJailBroken returns correct value', () async {
      methodChannelReturns['isJailBroken'] = true;
      expect(await detection.isJailBroken, true);

      methodChannelReturns['isJailBroken'] = false;
      expect(await detection.isJailBroken, false);

      methodChannelReturns['isJailBroken'] = null;
      expect(await detection.isJailBroken, false); // Default is false

      expect(log.length, 3);
      expect(log.every((call) => call.method == 'isJailBroken'), true);
    });

    test('isRealDevice returns correct value', () async {
      methodChannelReturns['isRealDevice'] = true;
      expect(await detection.isRealDevice, true);

      methodChannelReturns['isRealDevice'] = false;
      expect(await detection.isRealDevice, false);

      methodChannelReturns['isRealDevice'] = null;
      expect(await detection.isRealDevice, false); // Default is false

      expect(log.length, 3);
      expect(log.every((call) => call.method == 'isRealDevice'), true);
    });

    test('isDevMode returns correct value', () async {
      methodChannelReturns['isDevMode'] = true;
      expect(await detection.isDevMode, true);

      methodChannelReturns['isDevMode'] = false;
      expect(await detection.isDevMode, false);

      methodChannelReturns['isDevMode'] = null;
      expect(await detection.isDevMode, false); // Default is false

      expect(log.length, 3);
      expect(log.every((call) => call.method == 'isDevMode'), true);
    });

    test('isDebugged returns correct value', () async {
      methodChannelReturns['isDebugged'] = true;
      expect(await detection.isDebugged, true);

      methodChannelReturns['isDebugged'] = false;
      expect(await detection.isDebugged, false);

      methodChannelReturns['isDebugged'] = null;
      expect(await detection.isDebugged, false); // Default is false

      expect(log.length, 3);
      expect(log.every((call) => call.method == 'isDebugged'), true);
    });

    test('isTampered returns correct value', () async {
      const bundleId = 'com.example.test';

      methodChannelReturns['isTampered'] = true;
      expect(await detection.isTampered(bundleId), true);
      expect(log.last, isMethodCall('isTampered', arguments: {'bundleId': bundleId}));

      methodChannelReturns['isTampered'] = false;
      expect(await detection.isTampered(bundleId), false);

      methodChannelReturns['isTampered'] = null;
      expect(await detection.isTampered(bundleId), false); // Default is false

      expect(log.length, 3);
      expect(log.every((call) => call.method == 'isTampered'), true);
    });

    test('isOnExternalStorage returns correct value', () async {
      methodChannelReturns['isOnExternalStorage'] = true;
      expect(await detection.isOnExternalStorage, true);

      methodChannelReturns['isOnExternalStorage'] = false;
      expect(await detection.isOnExternalStorage, false);

      methodChannelReturns['isOnExternalStorage'] = null;
      expect(await detection.isOnExternalStorage, false); // Default is false

      expect(log.length, 3);
      expect(log.every((call) => call.method == 'isOnExternalStorage'), true);
    });

    group('isNotTrust', () {
      test('returns true when an error occurs during checks', () async {
        throwException = true;
        expect(await detection.isNotTrust, true);
      });

      test('calculates correct value based on individual checks (Generic)', () async {
        // Setup a matrix of tests for different states
        final testCases = [
          {'jailBroken': false, 'realDevice': true, 'onExternalStorage': false, 'expected': false},
          {'jailBroken': true, 'realDevice': true, 'onExternalStorage': false, 'expected': true},
          {'jailBroken': false, 'realDevice': false, 'onExternalStorage': false, 'expected': true},
        ];

        for (var testCase in testCases) {
          methodChannelReturns['isJailBroken'] = testCase['jailBroken'];
          methodChannelReturns['isRealDevice'] = testCase['realDevice'];
          methodChannelReturns['isOnExternalStorage'] = testCase['onExternalStorage'];

          expect(await detection.isNotTrust, testCase['expected'], reason: 'Failed for case: $testCase');
        }
      });

      test('returns false when device is trusted (not jailbroken, real device, not android)', () async {
        detection.debugIsAndroidOverride = false;
        methodChannelReturns['isJailBroken'] = false;
        methodChannelReturns['isRealDevice'] = true;
        final result = await detection.isNotTrust;
        expect(result, isFalse);
      });

      group('Platform.isAndroid branching', () {
        setUp(() {
          detection.debugIsAndroidOverride = true;
        });

        test('returns false when device is trusted (not jailbroken, real device, not on external storage)', () async {
          methodChannelReturns['isJailBroken'] = false;
          methodChannelReturns['isRealDevice'] = true;
          methodChannelReturns['isOnExternalStorage'] = false;
          final result = await detection.isNotTrust;
          expect(result, isFalse);
        });

        test('returns true when device is on external storage (Android specific)', () async {
          methodChannelReturns['isJailBroken'] = false;
          methodChannelReturns['isRealDevice'] = true;
          methodChannelReturns['isOnExternalStorage'] = true;
          final result = await detection.isNotTrust;
          expect(result, isTrue);
        });
      });
    });
  });
}
