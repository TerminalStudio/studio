import 'package:flutter/widgets.dart';

extension TargetPlatformExtension on TargetPlatform {
  bool get isApple =>
      this == TargetPlatform.iOS || this == TargetPlatform.macOS;

  bool get isDesktop =>
      this == TargetPlatform.linux ||
      this == TargetPlatform.macOS ||
      this == TargetPlatform.windows;
}
