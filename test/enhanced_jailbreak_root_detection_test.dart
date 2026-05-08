import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enhanced_jailbreak_root_detection/enhanced_jailbreak_root_detection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EnhancedJailbreakRootDetection', () {
    late EnhancedJailbreakRootDetection plugin;
    final List<MethodCall> log = <MethodCall>[];
    Object? methodChannelResponse;

    setUp(() {
      plugin = EnhancedJailbreakRootDetection.instance;
      log.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(plugin.methodChannel,
              (MethodCall methodCall) async {
        log.add(methodCall);
        return methodChannelResponse;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(plugin.methodChannel, null);
    });

    group('checkForIssues', () {
      test('returns mapped issues when method channel returns a valid list',
          () async {
        methodChannelResponse = ['jailbreak', 'proxied', 'unknown_issue'];

        final issues = await plugin.checkForIssues;

        expect(
          issues,
          [
            JailbreakIssue.jailbreak,
            JailbreakIssue.proxied,
            JailbreakIssue.unknown,
          ],
        );
        expect(log, hasLength(1));
        expect(log.first.method, 'checkForIssues');
      });

      test('returns an empty list when method channel returns null', () async {
        methodChannelResponse = null;

        final issues = await plugin.checkForIssues;

        expect(issues, []);
        expect(log, hasLength(1));
      });

      test('handles null elements within the list', () async {
        methodChannelResponse = ['jailbreak', null, 'debugged'];

        final issues = await plugin.checkForIssues;

        expect(
          issues,
          [
            JailbreakIssue.jailbreak,
            JailbreakIssue.unknown,
            JailbreakIssue.debugged,
          ],
        );
        expect(log, hasLength(1));
      });

      test('handles empty list from method channel', () async {
        methodChannelResponse = <dynamic>[];

        final issues = await plugin.checkForIssues;

        expect(issues, []);
        expect(log, hasLength(1));
      });
    });
  });
}
