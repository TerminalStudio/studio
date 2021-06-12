import 'package:flutter/widgets.dart';
import 'package:xterm/terminal/terminal_ui_interaction.dart';

abstract class TerminalIntent extends Intent {
  const TerminalIntent(this.isEnabled);

  final bool isEnabled;

  String get name;
}

class FontSizeIncreaseIntent extends TerminalIntent {
  const FontSizeIncreaseIntent(this.pixels, bool isEnabled) : super(isEnabled);

  final int pixels;

  @override
  String get name => 'Zoom in';
}

class FontSizeDecreaseIntent extends TerminalIntent {
  const FontSizeDecreaseIntent(this.pixels, bool isEnabled) : super(isEnabled);

  final int pixels;

  @override
  String get name => 'Zoom out';
}

class CopyIntent extends TerminalIntent {
  const CopyIntent(this.terminal, bool isEnabled) : super(isEnabled);

  final TerminalUiInteraction terminal;

  @override
  String get name => 'Copy';
}

class PasteIntent extends TerminalIntent {
  const PasteIntent(this.terminal, bool isEnabled) : super(isEnabled);

  final TerminalUiInteraction terminal;

  @override
  String get name => 'Paste';
}

class SelectAllIntent extends TerminalIntent {
  const SelectAllIntent(this.terminal, bool isEnabled) : super(isEnabled);

  final TerminalUiInteraction terminal;

  @override
  String get name => 'Select all';
}

class ClearIntent extends TerminalIntent {
  const ClearIntent(this.terminal, bool isEnabled) : super(isEnabled);

  final TerminalUiInteraction terminal;

  @override
  String get name => 'Clear';
}

class KillIntent extends TerminalIntent {
  const KillIntent(this.terminal, bool isEnabled) : super(isEnabled);

  final TerminalUiInteraction terminal;

  @override
  String get name => 'Kill';
}
