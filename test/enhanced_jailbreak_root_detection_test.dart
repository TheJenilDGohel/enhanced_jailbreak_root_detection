import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enhanced_jailbreak_root_detection/enhanced_jailbreak_root_detection.dart';
import 'dart:io';

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

    // We will set return values for method channel based on method name
    Map<String, dynamic> methodChannelReturns = {};

    setUp(() {
      log.clear();
      methodChannelReturns.clear();

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(detection.methodChannel, (MethodCall methodCall) async {
        log.add(methodCall);
        return methodChannelReturns[methodCall.method];
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(detection.methodChannel, null);
    });

    test('checkForIssues returns parsed list of issues', () async {
      methodChannelReturns['checkForIssues'] = ["jailbreak", "debugged", "unknown_issue"];

      final issues = await detection.checkForIssues;

      expect(log, <Matcher>[isMethodCall('checkForIssues', arguments: null)]);
      expect(issues, [
        JailbreakIssue.jailbreak,
        JailbreakIssue.debugged,
        JailbreakIssue.unknown
      ]);
    });

    test('checkForIssues returns empty list when null is returned', () async {
      methodChannelReturns['checkForIssues'] = null;

      final issues = await detection.checkForIssues;

      expect(log, <Matcher>[isMethodCall('checkForIssues', arguments: null)]);
      expect(issues, []);
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
        // Mock to throw an error
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(detection.methodChannel, (MethodCall methodCall) async {
          throw Exception('Platform exception');
        });

        expect(await detection.isNotTrust, true);
      });

      test('calculates correct value based on individual checks', () async {
        // Setup a matrix of tests for different states
        final testCases = [
          {'jailBroken': false, 'realDevice': true, 'onExternalStorage': false, 'expected': false},
          {'jailBroken': true, 'realDevice': true, 'onExternalStorage': false, 'expected': true},
          {'jailBroken': false, 'realDevice': false, 'onExternalStorage': false, 'expected': true},
          {'jailBroken': false, 'realDevice': true, 'onExternalStorage': true, 'expectedAndroid': true, 'expectedOther': false},
        ];

        for (var testCase in testCases) {
          methodChannelReturns['isJailBroken'] = testCase['jailBroken'];
          methodChannelReturns['isRealDevice'] = testCase['realDevice'];
          methodChannelReturns['isOnExternalStorage'] = testCase['onExternalStorage'];

          final expected = (Platform.isAndroid && testCase.containsKey('expectedAndroid'))
              ? testCase['expectedAndroid']
              : (testCase.containsKey('expectedOther') ? testCase['expectedOther'] : testCase['expected']);

          expect(await detection.isNotTrust, expected, reason: 'Failed for case: $testCase');
        }
      });
    });
  });
}
