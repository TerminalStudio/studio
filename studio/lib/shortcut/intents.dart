import 'package:flutter/widgets.dart';

class FontSizeIncreaseIntent extends Intent {
  const FontSizeIncreaseIntent(this.pixels);

  final int pixels;
}

class FontSizeDecreaseIntent extends Intent {
  const FontSizeDecreaseIntent(this.pixels);

  final int pixels;
}
