import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';

class TerminalContextMenu extends StatefulWidget {
  const TerminalContextMenu({
    super.key,
    required this.terminal,
    required this.terminalController,
  });

  final Terminal terminal;

  final TerminalController terminalController;

  @override
  TerminalContextMenuState createState() => TerminalContextMenuState();
}

class TerminalContextMenuState extends State<TerminalContextMenu>
    with ContextMenuStateMixin {
  @override
  void initState() {
    widget.terminalController.addListener(_onSelectionChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.terminalController.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TerminalContextMenu oldWidget) {
    if (oldWidget.terminalController != widget.terminalController) {
      oldWidget.terminalController.removeListener(_onSelectionChanged);
      widget.terminalController.addListener(_onSelectionChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onSelectionChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.terminalController.selection;
    return cardBuilder(
      context,
      [
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            "Copy",
            icon: const Icon(Icons.copy),
            shortcutLabel: 'Ctrl+C',
            onPressed: selection != null
                ? () => handlePressed(context, _handleCopy)
                : null,
          ),
        ),
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            "Paste",
            icon: const Icon(Icons.paste),
            shortcutLabel: 'Ctrl+V',
            onPressed: () => handlePressed(context, _handlePaste),
          ),
        ),
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            "Select All",
            icon: const Icon(Icons.select_all),
            shortcutLabel: 'Ctrl+A',
            onPressed: () => handlePressed(context, _handleSelectAll),
          ),
        ),
        buildDivider(),
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            "File Manager",
            icon: const Icon(Icons.folder),
            shortcutLabel: 'Ctrl+Shift+F',
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Future<void> _handleCopy() async {
    final selection = widget.terminalController.selection;

    if (selection == null) {
      return;
    }

    final text = widget.terminal.buffer.getText(selection);

    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);

    if (data == null) {
      return;
    }

    final text = data.text;

    if (text == null) {
      return;
    }

    widget.terminal.paste(text);
  }

  Future<void> _handleSelectAll() async {
    final terminal = widget.terminal;
    widget.terminalController.setSelection(
      BufferRangeLine(
        CellOffset(0, terminal.buffer.height - terminal.viewHeight),
        CellOffset(terminal.viewWidth, terminal.buffer.height - 1),
      ),
    );
  }
}
