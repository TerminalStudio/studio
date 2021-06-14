import 'package:flutter/widgets.dart';
import 'package:xterm/terminal/terminal_ui_interaction.dart';

class TerminalShortcut {
  final Future Function(TerminalUiInteraction) _onExecute;
  final Future<bool> Function(TerminalUiInteraction)? _onIsAvailable;

  final Intent intent;

  const TerminalShortcut(
      {required this.name,
      required Future Function(TerminalUiInteraction) onExecute,
      Future<bool> Function(TerminalUiInteraction)? onIsAvailable,
      required this.keyCombinations,
      required this.intent})
      : _onExecute = onExecute,
        _onIsAvailable = onIsAvailable;

  final List<LogicalKeySet> keyCombinations;
  final String name;

  Future<bool> isAvailable(TerminalUiInteraction terminal) async =>
      _onIsAvailable == null ? true : await _onIsAvailable!(terminal);

  Future execute(TerminalUiInteraction terminal) async =>
      await _onExecute(terminal);
}
