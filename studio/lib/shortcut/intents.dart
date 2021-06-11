import 'package:flutter/widgets.dart';
import 'package:xterm/terminal/terminal_ui_interaction.dart';

class FontSizeIncreaseIntent extends Intent {
  const FontSizeIncreaseIntent(this.pixels);

  final int pixels;
}

class FontSizeDecreaseIntent extends Intent {
  const FontSizeDecreaseIntent(this.pixels);

  final int pixels;
}

class CopyIntent extends Intent {
  const CopyIntent(this.terminal);

  final TerminalUiInteraction terminal;
}

class PasteIntent extends Intent {
  const PasteIntent(this.terminal);

  final TerminalUiInteraction terminal;
}
