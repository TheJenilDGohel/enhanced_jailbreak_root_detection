import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents various security issues that can be detected on a device.
///
/// This enum covers jailbreak/root detection, debugging tools, and other
/// security concerns on both Android and iOS platforms.
enum JailbreakIssue {
  /// Device is jailbroken (iOS) or rooted (Android).
  jailbreak,

  /// Device is not a real physical device (emulator/simulator detected).
  notRealDevice,

  /// Network traffic is being proxied or intercepted.
  proxied,

  /// A debugger is attached to the application.
  debugged,

  /// Developer mode is enabled on the device (Android).
  devMode,

  /// Application is being reverse engineered.
  reverseEngineered,

  /// Frida instrumentation framework detected (Android/iOS).
  fridaFound,

  /// Cydia package manager detected (iOS jailbreak indicator).
  cydiaFound,

  /// Application binary has been tampered with (iOS).
  tampered,

  /// Application is installed on external storage (Android).
  onExternalStorage,

  /// Unknown or unclassified security issue.
  unknown;

  /// Converts a string value to its corresponding [JailbreakIssue] enum.
  ///
  /// Returns [JailbreakIssue.unknown] if the value doesn't match any known issue.
  static JailbreakIssue fromString(String value) {
    if (value == "jailbreak") {
      return JailbreakIssue.jailbreak;
    }
    if (value == "notRealDevice") {
      return JailbreakIssue.notRealDevice;
    }
    if (value == "proxied") {
      return JailbreakIssue.proxied;
    }
    if (value == "debugged") {
      return JailbreakIssue.debugged;
    }
    if (value == "devMode") {
      return JailbreakIssue.devMode;
    }
    if (value == "reverseEngineered") {
      return JailbreakIssue.reverseEngineered;
    }
    if (value == "fridaFound") {
      return JailbreakIssue.fridaFound;
    }
    if (value == "cydiaFound") {
      return JailbreakIssue.cydiaFound;
    }
    if (value == "tampered") {
      return JailbreakIssue.tampered;
    }
    if (value == "onExternalStorage") {
      return JailbreakIssue.onExternalStorage;
    }

    return JailbreakIssue.unknown;
  }
}

/// Enhanced jailbreak and root detection plugin for Flutter.
///
/// This plugin provides comprehensive security checks for detecting jailbroken
/// iOS devices and rooted Android devices, including Frida detection, debugger
/// detection, and other security concerns.
///
/// Use the singleton [instance] to access all detection methods.
///
/// Example:
/// ```dart
/// final detection = EnhancedJailbreakRootDetection.instance;
/// final isJailBroken = await detection.isJailBroken;
/// if (isJailBroken) {
///   print('Device security is compromised!');
/// }
/// ```
class EnhancedJailbreakRootDetection {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('enhanced_jailbreak_root_detection');

  static final EnhancedJailbreakRootDetection _instance =
      EnhancedJailbreakRootDetection();

  /// Returns the singleton instance of [EnhancedJailbreakRootDetection].
  static EnhancedJailbreakRootDetection get instance => _instance;

  /// Performs comprehensive security checks and returns all detected issues.
  ///
  /// This method runs all available security checks and returns a list of
  /// [JailbreakIssue] enums representing detected security concerns.
  ///
  /// Supported on both Android and iOS platforms.
  ///
  /// Returns an empty list if no issues are detected.
  ///
  /// Example:
  /// ```dart
  /// final issues = await EnhancedJailbreakRootDetection.instance.checkForIssues;
  /// for (var issue in issues) {
  ///   print('Detected issue: $issue');
  /// }
  /// ```
  Future<List<JailbreakIssue>> get checkForIssues async {
    final issues =
        await methodChannel.invokeMethod<List<dynamic>>('checkForIssues');

    return issues?.map((e) => JailbreakIssue.fromString(e ?? '')).toList() ??
        [];
  }

  /// Checks if the device is jailbroken (iOS) or rooted (Android).
  ///
  /// Returns `true` if jailbreak or root access is detected, `false` otherwise.
  ///
  /// **Platform Support:** iOS and Android
  ///
  /// On Android, this uses RootBeer library to detect:
  /// - Root management apps (SuperSU, Magisk, etc.)
  /// - Root cloaking apps
  /// - Dangerous system properties
  /// - Root native binaries (su, busybox)
  ///
  /// On iOS, this uses IOSSecuritySuite to detect:
  /// - Cydia installation
  /// - Jailbreak file paths
  /// - Suspicious dylibs
  ///
  /// Example:
  /// ```dart
  /// final isJailBroken = await EnhancedJailbreakRootDetection.instance.isJailBroken;
  /// if (isJailBroken) {
  ///   // Handle compromised device
  /// }
  /// ```
  Future<bool> get isJailBroken async =>
      await methodChannel.invokeMethod<bool>('isJailBroken') ?? false;

  /// Checks if the device is a real physical device or an emulator/simulator.
  ///
  /// Returns `true` if running on a real device, `false` if running on emulator/simulator.
  ///
  /// **Platform Support:** iOS and Android
  ///
  /// This check is important because emulators are often used for:
  /// - App analysis and reverse engineering
  /// - Automated attacks
  /// - Testing fraud scenarios
  ///
  /// Example:
  /// ```dart
  /// final isRealDevice = await EnhancedJailbreakRootDetection.instance.isRealDevice;
  /// if (!isRealDevice) {
  ///   print('Running on emulator/simulator');
  /// }
  /// ```
  Future<bool> get isRealDevice async =>
      await methodChannel.invokeMethod<bool>('isRealDevice') ?? false;

  /// Checks if developer mode is enabled on the device.
  ///
  /// Returns `true` if developer mode is enabled, `false` otherwise.
  ///
  /// **Platform Support:** Android only (returns `false` on iOS)
  ///
  /// Developer mode on Android enables:
  /// - USB debugging
  /// - Mock locations
  /// - Install from unknown sources
  ///
  /// Example:
  /// ```dart
  /// final isDevMode = await EnhancedJailbreakRootDetection.instance.isDevMode;
  /// if (isDevMode) {
  ///   print('Developer mode is enabled');
  /// }
  /// ```
  Future<bool> get isDevMode async =>
      await methodChannel.invokeMethod<bool>('isDevMode') ?? false;

  /// Checks if a debugger is attached to the application.
  ///
  /// Returns `true` if a debugger is detected, `false` otherwise.
  ///
  /// **Platform Support:** iOS and Android
  ///
  /// On Android, uses ptrace to detect debugging.
  /// On iOS, uses IOSSecuritySuite debugger detection.
  ///
  /// Example:
  /// ```dart
  /// final isDebugged = await EnhancedJailbreakRootDetection.instance.isDebugged;
  /// if (isDebugged) {
  ///   print('Debugger detected!');
  /// }
  /// ```
  Future<bool> get isDebugged async =>
      await methodChannel.invokeMethod<bool>('isDebugged') ?? false;

  /// Checks if the iOS application binary has been tampered with.
  ///
  /// Returns `true` if tampering is detected, `false` otherwise.
  ///
  /// **Platform Support:** iOS only (returns `false` on Android)
  ///
  /// This method verifies the app's code signature and bundle ID to detect:
  /// - Repackaged applications
  /// - Modified binaries
  /// - Sideloaded apps
  ///
  /// **Parameters:**
  /// - [bundleId]: Your app's bundle identifier (e.g., 'com.example.myapp')
  ///
  /// Example:
  /// ```dart
  /// const bundleId = 'com.example.myapp';
  /// final isTampered = await EnhancedJailbreakRootDetection.instance.isTampered(bundleId);
  /// if (isTampered) {
  ///   print('App binary has been tampered with!');
  /// }
  /// ```
  Future<bool> isTampered(String bundleId) async =>
      await methodChannel
          .invokeMethod<bool>('isTampered', {'bundleId': bundleId}) ??
      false;

  /// Checks if the application is installed on external storage.
  ///
  /// Returns `true` if installed on external storage, `false` otherwise.
  ///
  /// **Platform Support:** Android only (returns `false` on iOS)
  ///
  /// Apps on external storage are more vulnerable because:
  /// - External storage can be removed/replaced
  /// - Files are accessible without root
  /// - Lower security guarantees
  ///
  /// Example:
  /// ```dart
  /// final isOnExternalStorage = await EnhancedJailbreakRootDetection.instance.isOnExternalStorage;
  /// if (isOnExternalStorage) {
  ///   print('App is on external storage - security risk!');
  /// }
  /// ```
  Future<bool> get isOnExternalStorage async =>
      await methodChannel.invokeMethod<bool>('isOnExternalStorage') ?? false;

  /// Performs a comprehensive trust check combining multiple security indicators.
  ///
  /// Returns `true` if the device/app is **NOT** trustworthy, `false` if trustworthy.
  ///
  /// **Platform Support:** iOS and Android
  ///
  /// This combines checks for:
  /// - Jailbreak/root detection
  /// - Real device verification
  /// - External storage (Android only)
  ///
  /// On Android: Returns `true` if jailbroken OR emulator OR external storage
  /// On iOS: Returns `true` if jailbroken OR simulator
  ///
  /// This is a convenient method for quick security assessment.
  ///
  /// Example:
  /// ```dart
  /// final isNotTrust = await EnhancedJailbreakRootDetection.instance.isNotTrust;
  /// if (isNotTrust) {
  ///   // Block sensitive operations
  ///   showDialog(
  ///     context: context,
  ///     builder: (_) => AlertDialog(
  ///       title: Text('Security Warning'),
  ///       content: Text('This device is not trusted'),
  ///     ),
  ///   );
  /// }
  /// ```
  /// Override for testing purposes.
  @visibleForTesting
  bool? debugIsAndroidOverride;

  bool get _isAndroid => debugIsAndroidOverride ?? Platform.isAndroid;

  Future<bool> get isNotTrust async {
    try {
      final bool jailBroken = await isJailBroken;
      final bool realDevice = await isRealDevice;
      if (_isAndroid) {
        final bool onExternalStorage = await isOnExternalStorage;
        return jailBroken || !realDevice || onExternalStorage;
      }
      return jailBroken || !realDevice;
    } catch (e) {
      return true;
    }
  }
}
