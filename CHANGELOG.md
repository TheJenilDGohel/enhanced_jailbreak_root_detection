## 0.0.4-dev.1

* **Swift Package Manager Support:** Added `ios/enhanced_jailbreak_root_detection/Package.swift` alongside existing CocoaPods setup. No breaking changes for existing CocoaPods users.
* Restructured iOS source files to SPM-compliant `Sources/` layout.
* Updated podspec `source_files` to match the new directory structure.
* Added SPM CI build leg to GitHub Actions workflow.

## 0.0.3

* **Hardened Security:** Fixed multiple File Descriptor (FD) leaks in Android system command execution via strict Kotlin `.use` blocks and resource management.
* **Open-Source Excellence:** Completely revamped documentation with premium banner, architecture diagrams, and comprehensive setup guides.
* **Community Standards:** Added `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, and GitHub issue/PR templates.
* **Stability:** Fixed lint warnings and stabilized unit test suite with 100% pass rate.

## 0.0.2

* Updated README with professional documentation and roadmap.
* Bumped package version to `0.0.2`.
* Resolved complex merge conflicts from community contributions.
* Minor code cleanup and lint fixes.

## 0.0.1

* Initial release as enhanced fork of the original [jailbreak_root_detection](https://github.com/w3connext/jailbreak_root_detection) package
* **BREAKING**: Package renamed from `jailbreak_root_detection` to `enhanced_jailbreak_root_detection`
* Fixed deprecated package attribute in AndroidManifest.xml for Android Gradle Plugin compatibility
* Updated all Kotlin package paths from `com.w3conext.jailbreak_root_detection` to `com.w3conext.enhanced_jailbreak_root_detection`
* Updated JNI native function names in C++ code to match new package structure
* Fixed iOS podspec and Swift module imports to use new package name
* Updated example app with new package name and configuration
* Updated example app build.gradle namespace and applicationId
* Inherited all features from jailbreak_root_detection v1.2.0+1
* Uses RootBeer + DetectFrida for Android root detection
* Uses IOSSecuritySuite (~> 1.9.10) for iOS jailbreak detection
* Supports 16KB page sizes on Android
* Includes Frida detection and debugger checks

---

## Previous Versions (from original jailbreak_root_detection package)

## 1.2.0+1

* Improve Android and SDK Compatibility Without Over-Upgrading
* Acknowledgements: Thanks to @vicajilau for their PRs 🙏

## 1.2.0

* Added support for 16 KB page sizes
* Upgraded compileSdk and Gradle version
* Added background execution support
* Added null-safety support in `ExternalStorageCheck.kt`
* Acknowledgements: Thanks to @n0ks, @maeddin, @vicajilau, @anderscheow, and @bjlf12 for their PRs 🙏

## 1.1.6

* fix: TARGET_OS_SIMULATOR is deprecated in swift

## 1.1.5

* check has property namespace for Android

## 1.1.4

* Enhance security by adding more suspicious paths in iOS

## 1.1.3

* Add function is debugger on iOS and Android

## 1.1.2

* Check debugger on android

## 1.1.1

* Fixed bug pixel

## 1.1.0

* Add method `checkForIssues`

## 1.0.0

* Remove the function 'checkPSelectFlag' for the reverse engineering checker

## 0.0.7

* Update version IOSSecuritySuite to 1.9.10

## 0.0.6

* Change logic check detect frida to jvm

## 0.0.5

* Change library for check detect frida

## 0.0.4

* Config jniLibs by "armeabi-v7a", "arm64-v8a", "x86", "x86_64"

## 0.0.3

* Config ndk abiFilters "armeabi-v7a", "arm64-v8a", "x86", "x86_64"

## 0.0.2

* Remove config application in AndroidManifest.xml

## 0.0.1

* Uses RootBeer + DetectFrida for Android root detection and IOSSecuritySuite for iOS jailbreak detection.
