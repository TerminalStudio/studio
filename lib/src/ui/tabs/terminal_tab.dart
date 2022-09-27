import 'dart:convert';

import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/scheduler.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio/src/ui/tabs/terminal_menu.dart';
import 'package:xterm/xterm.dart';

class TerminalTab extends TabItem {
  TerminalTab() {
    init;
    content.value = TerminalTabView(this);
  }

  final terminal = Terminal(maxLines: 10000);

  final terminalController = TerminalController();

  var terminalTitle = '';

  late final pty = Pty.start(
    'zsh',
    columns: terminal.viewWidth,
    rows: terminal.viewHeight,
  );

  late final init = () {
    pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(terminal.write);

    pty.exitCode.then((code) {
      detach();
    });

    terminal.onTitleChange = (title) {
      terminalTitle = title;
      updateTitle();
    };

    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        updateTitle();
      });
    };
  }();

  void updateTitle() {
    title.value = Text(
      '$terminalTitle — ${terminal.viewWidth}x${terminal.viewHeight}',
    );
  }
}

class TerminalTabView extends ConsumerStatefulWidget {
  const TerminalTabView(this.tab, {super.key});

  final TerminalTab tab;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TerminalTabViewState();
}

class _TerminalTabViewState extends ConsumerState<TerminalTabView> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      key: ValueKey(widget.tab),
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: TerminalView(
          widget.tab.terminal,
          controller: widget.tab.terminalController,
          onSecondaryTapDown: (_, __) => showMenu(),
          backgroundOpacity: 0,
          autofocus: true,
        ),
      ),
    );
  }

  void showMenu() {
    final menu = TerminalContextMenu(
      terminal: widget.tab.terminal,
      terminalController: widget.tab.terminalController,
    );
    context.contextMenuOverlay.show(menu);
  }
}
