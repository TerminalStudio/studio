import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studio/src/plugins/file_manager_plugin.dart';
import 'package:studio/src/ui/tabs/plugin_tab/plugin_tab.dart';
import 'package:studio/src/ui/tabs/terminal_tab/terminal_tab.dart';
import 'package:xterm/xterm.dart';

class TerminalContextMenu extends StatefulWidget {
  const TerminalContextMenu({
    super.key,
    required this.tab,
  });

  final TerminalTab tab;

  @override
  TerminalContextMenuState createState() => TerminalContextMenuState();
}

class TerminalContextMenuState extends State<TerminalContextMenu>
    with ContextMenuStateMixin {
  TerminalTab get tab => widget.tab;

  Terminal get terminal => tab.terminal;

  TerminalController get terminalController => tab.terminalController;

  @override
  void initState() {
    terminalController.addListener(_onSelectionChanged);
    super.initState();
  }

  @override
  void dispose() {
    terminalController.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TerminalContextMenu oldWidget) {
    if (oldWidget.tab.terminalController != widget.tab.terminalController) {
      oldWidget.tab.terminalController.removeListener(_onSelectionChanged);
      widget.tab.terminalController.addListener(_onSelectionChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onSelectionChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return cardBuilder(
      context,
      [
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            "Copy",
            icon: const Icon(Icons.copy),
            shortcutLabel: 'Ctrl+C',
            onPressed: terminalController.selection != null
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
            icon: const Icon(Icons.folder_open),
            shortcutLabel: 'Ctrl+Shift+F',
            onPressed: () => handlePressed(context, _handleOpenFileManager),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCopy() async {
    final selection = terminalController.selection;

    if (selection == null) {
      return;
    }

    final text = terminal.buffer.getText(selection);

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

    terminal.paste(text);
  }

  Future<void> _handleSelectAll() async {
    terminalController.setSelection(
      BufferRangeLine(
        CellOffset(0, terminal.buffer.height - terminal.viewHeight),
        CellOffset(terminal.viewWidth, terminal.buffer.height - 1),
      ),
    );
  }

  Future<void> _handleOpenFileManager() async {
    final parent = tab.parent;
    if (parent == null) {
      return;
    }

    final pluginTab = PluginTab(tab.host, FileManagerPlugin());

    parent.insert(parent.indexOf(tab) + 1, pluginTab);

    parent.activate(pluginTab);
  }
}
